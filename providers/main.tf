terraform{
    required_providers{
        aws = {
           source = "hashicorp/aws"
           version = "~> 3.0"
        }
    }
}

provider "aws"{
      region = "us-east-1"
}



resource "aws_instance" "example"{
    ami = "ami-0427090fd1714168b"
    instance_type = "t2.micro"
}