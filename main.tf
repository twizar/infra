terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.2.0"
    }
  }

  backend "s3" {
    bucket = "twizar-infra"
    key = "terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  region = "us-east-1"
  alias = "Virginia"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key  = var.mongodbatlas_private_key
}

variable "aws_access_key" {
  description = "AWS access key"
}
variable "aws_secret_key" {
  description = "AWS secret key"
}
variable "aws_region" {
  default = "eu-central-1"
  description = "AWS region"
}

variable "google_client_id" {
  type = string
}
variable "google_client_client_secret" {
  type = string
}
variable "facebook_client_id" {
  type = string
}
variable "facebook_client_client_secret" {
  type = string
}

variable "lambda_stub_file" {
  default = "lambda_stub.zip"
}
variable "lambda_users_regular_group" {
  default = "RegularUsers"
}

variable "mongo_conn_url" {}
variable "http_header_access_control_allow_origin" {}

variable "api_gateway_stage_name" {
  default = "default"
}

variable "mongodbatlas_public_key" {}
variable "mongodbatlas_private_key" {}
variable "mongodbatlas_region" {
  default = "EU_CENTRAL_1"
}
variable "mongodbatlas_org_id" {}
