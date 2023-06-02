subnet_ids = ["subnet-0c54ecc2fa3e67790","subnet-092dec3db51849867","subnet-05e439b9dc7303f73"]
security_group_id = ["sg-0d9b5e93485a658c6"]
project_name       = "Data-preparation-pipeline"
environment        = "dev"
source_repo_name   = "Data-preparation-pipeline"
source_repo_branch = "master"
lambda_runtime = "python3.9"
stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "apply", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "ApplyOutput" },
]
build_projects = ["validate", "plan", "apply", "destroy"]



