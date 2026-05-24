provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "digvijay-terraform-state-2026"
  force_destroy = true

  tags = {
    Name    = "demo-project-terraform-state"
    Project = "demo-project"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
