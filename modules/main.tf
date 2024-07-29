provider "aws"{
    region = "us-east-1"
}
module "ec2instance"{
    source = "./ec2instance"
    ami = "ami-0427090fd1714168b"
    instance_type = "t2.micro"
}