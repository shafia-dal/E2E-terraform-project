provider "aws" {
  region  = "us-east-1"
<<<<<<< HEAD
  assume_role {
    role_arn = "arn:aws:iam::091846656105:role/operisoft-admin"
  }
=======
  
>>>>>>> 886fecc80703f827e6505a8eb1e22713511d81a5
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
<<<<<<< HEAD
}

=======
  backend "s3" {
    bucket = "e2e-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
>>>>>>> 886fecc80703f827e6505a8eb1e22713511d81a5
