import os
import boto3
import json


def _generate_steps(accountID: str, environment: str = "DEV"):
    deltalakeJar = f"s3://{accountID}-{environment.lower()}-configs/deltalake/jars/deltalake-processing-assembly-1.0.jar"

    configs = [
        {
            'Name': 'RAW-CopyToProcessing',
            'ActionOnFailure': 'TERMINATE_CLUSTER',
            'HadoopJarStep': {
                    'Jar': 'command-runner.jar',
                    'Args': [
                        's3-dist-cp',
                        '--src',
                        f's3://{accountID}-{environment.lower()}-kafka-raw/cdc/kafka/',
                        '--dest',
                        f's3://{accountID}-{environment.lower()}-kafka-raw/cdc/processing/',
                        '--deleteOnSuccess'
                    ]
            },
        },
        {
            'Name': 'RAW-ProcessingCDC-DATAFEEDER_register',
            'ActionOnFailure': 'TERMINATE_CLUSTER',
            'HadoopJarStep': {
                    'Jar': 'command-runner.jar',
                    'Args': [
                        "spark-submit",
                        "--conf",
                        "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension",
                        "--conf",
                        "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog",
                        "--class",
                        "deltaprocessing.Main",
                        deltalakeJar,
                        "{ \"service\": \"emr\", \"params\": { \"configPath\": \"s3://" + accountID +
                        "-" + environment.lower() +
                        "-configs/deltalake/configs/config-DATAFEEDER_register.dev.json\" } }"
                    ]
            },
        },
        {
            'Name': 'RAW-ProcessingCDC-DATAFEEDER_tracker',
            'ActionOnFailure': 'TERMINATE_CLUSTER',
            'HadoopJarStep': {
                    'Jar': 'command-runner.jar',
                    'Args': [
                        "spark-submit",
                        "--conf",
                        "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension",
                        "--conf",
                        "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog",
                        "--class",
                        "deltaprocessing.Main",
                        deltalakeJar,
                        "{ \"service\": \"emr\", \"params\": { \"configPath\": \"s3://" + accountID +
                        "-" + environment.lower() +
                        "-configs/deltalake/configs/config-DATAFEEDER_tracker.dev.json\" } }"
                    ]
            },
        },
        {
            'Name': 'RAW-CopyToArchive',
            'ActionOnFailure': 'TERMINATE_CLUSTER',
            'HadoopJarStep': {
                    'Jar': 'command-runner.jar',
                    'Args': [
                        's3-dist-cp',
                        '--src',
                        f's3://{accountID}-{environment.lower()}-kafka-raw/cdc/processing/',
                        '--dest',
                        f's3://{accountID}-{environment.lower()}-kafka-raw/cdc/archive/',
                        '--deleteOnSuccess'
                    ]
            },
        }
    ]
    return configs


def lambda_handler(event, context):
    """Create a temporary cluster to process cdc files with deltalake
    """

    emr = boto3.client("emr")

    # Get Account ID
    accountID = boto3.client('sts').get_caller_identity().get('Account')

    # Get region name
    runtime_region = os.environ['AWS_REGION']

    environment = os.environ['ENV']
    keyName = os.environ['KEY_NAME']
    masterInstanceType = os.environ['MASTER_INSTANCE_TYPE']
    coreInstanceType = os.environ['CORE_INSTANCE_TYPE']
    ec2MasterName = os.environ['EC2_MASTER_NAME']
    ec2CoreName = os.environ['EC2_CORE_NAME']
    instanceCount = int(os.environ['INSTANCE_COUNT'])
    ebsSizeGB = int(os.environ['EBS_SIZE_GB'])
    ec2SubnetId = os.environ['EC2_SUBNET_ID']

    logUri = f"s3n://aws-logs-{accountID}-{runtime_region}/elasticmapreduce/"
    releaseLabel = "emr-6.1.0"

    clusterName = f"{environment}-EMR-DELTALAKE-PROCESSING"

    steps = _generate_steps(accountID, environment)

    response = emr.run_job_flow(
        Name=clusterName,
        LogUri=logUri,
        ReleaseLabel=releaseLabel,
        Instances={
            'InstanceGroups': [
                {
                    'Name': ec2MasterName,
                    'Market': 'ON_DEMAND',
                    'InstanceRole': 'MASTER',
                    'InstanceType': masterInstanceType,
                    'InstanceCount': 1,
                    'EbsConfiguration': {
                        'EbsBlockDeviceConfigs': [
                            {
                                'VolumeSpecification': {
                                    'VolumeType': 'gp2',
                                    'SizeInGB': ebsSizeGB
                                },
                                'VolumesPerInstance': 1
                            },
                        ]
                    },
                },
                {
                    'Name': ec2CoreName,
                    'Market': 'ON_DEMAND',
                    'InstanceRole': 'CORE',
                    'InstanceType': coreInstanceType,
                    'InstanceCount': instanceCount,
                    'EbsConfiguration': {
                        'EbsBlockDeviceConfigs': [
                            {
                                'VolumeSpecification': {
                                    'VolumeType': 'gp2',
                                    'SizeInGB': ebsSizeGB
                                },
                                'VolumesPerInstance': 1
                            },
                        ]
                    }
                }
            ],
            'Ec2KeyName': keyName,
            'KeepJobFlowAliveWhenNoSteps': False,
            'Ec2SubnetId': ec2SubnetId,
        },
        Steps=steps,
        Applications=[
            {
                'Name': 'Hadoop'
            },
            {
                'Name': 'Spark'
            },
        ],
        Configurations=[
            {
                "Classification": "spark",
                "Properties": {"maximizeResourceAllocation": "true"}
            },
            {
                "Classification": "spark-hive-site",
                "Properties": {
                    "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
                }
            },
            {
                'Classification': 'spark-defaults',
                'Properties': {
                    "spark.sql.adaptative.enabled": "true"
                }
            }
        ],
        VisibleToAllUsers=True,
        JobFlowRole='EMR_EC2_DefaultRole',
        ServiceRole='EMR_DefaultRole',
        Tags=[
            {
                'Key': 'env',
                'Value': environment
            },
        ],
        EbsRootVolumeSize=10,
        StepConcurrencyLevel=1
    )

    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
