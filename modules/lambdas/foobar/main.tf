module "foobar" {
  source = "../../../blueprints/lambda"

  function_name = "FOOBAR"
  path_module   = "${path.module}"
  region        = "us-east-1"
}

output "foobar" {
  value = module.foobar
}
