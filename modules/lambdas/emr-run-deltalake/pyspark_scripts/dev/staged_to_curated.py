"""
Yuri Niitsuma <ignitzhjfk@gmail.com>

Amazon EMR 6.0.1
Python 3.7.8
Spark 3.0.1


Run with
spark-submit --packages io.delta:delta-core_2.12:0.7.0 --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog" staged_to_curated.py

To play around
pyspark --packages io.delta:delta-core_2.12:0.7.0 --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
"""

import sys
import datetime
import json
import logging
import pyspark

from pyspark.sql.types import *
from pyspark.sql.functions import *
from pyspark.sql import SparkSession
from pyspark.sql import SQLContext


spark = SparkSession.builder \
    .appName("StagedToCurated") \
    .config("spark.jars.packages", "io.delta:delta-core_2.12:0.7.0") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("hive.metastore.client.factory.class", "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory") \
    .enableHiveSupport() \
    .getOrCreate()

sqlContext = SQLContext(spark.sparkContext)

params = {
    "glueDatabase": "datafeeder",
    "sourcePrefix": "s3://333728661073-dev-kafka-staged/",
    "targetPrefix": "s3://333728661073-dev-kafka-staged/",
    "tablesList": [
        {
            "database": "DATAFEEDER_register",
            "tables": [
                {"schema": "dbo", "name": "addresses"},
                {"schema": "dbo", "name": "companies"},
                {"schema": "dbo", "name": "persons"},
                {"schema": "dbo", "name": "persons_companies"}
            ]
        },
        {
            "database": "DATAFEEDER_tracker",
            "tables": [
                {"schema": "public", "name": "posts"},
                {"schema": "public", "name": "users"}
            ]
        }
    ]
}

glueDatabase = params.get("glueDatabase")
sourcePrefix = params.get("sourcePrefix")
targetPrefix = params.get("targetPrefix")
tablesList = params.get("tablesList")

assert(sourcePrefix is not None)
assert(targetPrefix is not None)
assert(tablesList is not None)


def getTablesOnGlue(glueDatabase: str):
    response = []
    for x in sqlContext.sql(f"show tables in {glueDatabase}").rdd.collect():
        response.append(x.tableName)
    return response


for tableObj in tablesList:
    database = tableObj.get("database")
    tables = tableObj.get("tables")
    assert(database is not None)
    assert(tables is not None)

    for table in tables:
        schemaName = table.get("schema")
        tableName = table.get("name")
        assert(schemaName is not None)
        assert(tableName is not None)

        glueTableName = f"{database.lower()}_{schemaName}_{tableName}"

        df = spark.read.format("delta").load(
            f"{sourcePrefix}/{database}/{schemaName}/{tableName}")

        if glueTableName in getTablesOnGlue(glueDatabase):
            df.write.mode("overwrite").insertInto(
                f'{glueDatabase}.{glueTableName}')
        else:
            # Maybe use partitionBy
            df.write.saveAsTable(f'{glueDatabase}.{glueTableName}')
