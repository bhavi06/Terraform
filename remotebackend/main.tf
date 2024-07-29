provider "aws"{
    region = "us-east-1"
}

resource "aws_instance" "ec2instanceweb" {
    ami = "ami-0427090fd1714168b"
    instance_type = "t2.micro"
}

resource "aws_s3_bucket" "tfstatebucket" {
     bucket = "s3terraformtfstate"
}

resource "aws_dynamodb_table" "terraform_lock" {
    name = "terraform-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute{
        name = "LockID"
        type = "S"

    }
}