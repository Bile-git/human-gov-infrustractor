terraform {
    backend "s3"{
        bucket = "tcb-devops-mod3-state-abs-poc"
        key = "teraform.tfstate"
        region = "us-east-2"
        encrypt = true
        dynamodb_table = "humangov-terraform-state-lock-table"
    }
}