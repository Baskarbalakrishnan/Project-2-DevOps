terraform {
  backend "s3" {
    bucket         = "dev-ops-project2026"    # <- create / replace
    key            = "project2/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "project2-tf-locks"          # the DynamoDB table you created
    encrypt        = true
  }
}
