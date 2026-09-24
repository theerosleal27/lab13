data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-7zh97qyv-vpc"]
  }
}

data "aws_subnet" "public1" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-7zh97qyv-public-subnet1"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_subnet" "public2" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-7zh97qyv-public-subnet2"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_security_group" "ssh" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-7zh97qyv-sg-ssh"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_security_group" "http" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-7zh97qyv-sg-http"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_security_group" "lb" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-7zh97qyv-sg-lb"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}