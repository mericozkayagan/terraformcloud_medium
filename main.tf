terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "mericozkayagan"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.10.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name        = "vpc"
    Environment = var.environment
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "gw3"
    Environment = var.environment
  }
}


resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.gw,
  ]
  tags = {
    Name        = "gw"
    Environment = var.environment
  }
}

resource "aws_subnet" "subnet-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name        = "subnet-a"
    Environment = var.environment
  }
}

resource "aws_subnet" "subnet-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name        = "subnet-b"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-a.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.route-table.id
}

