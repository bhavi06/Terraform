terraform{
    backend "s3"{
        key= "terraform.tfstate"
        bucket = "s3terraformtfstate"
        dynamodb_table = "terraform-lock"
        encrypt = true
        region = "us-east-1"
    }
}