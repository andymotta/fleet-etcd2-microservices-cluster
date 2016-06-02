# aws creds
variable "access_key" {}
variable "secret_key" {}
variable "key_name" {}
variable "key_file" {}

variable "name" { default = "Fleet Demo" }

variable "yourPubIP" { default = "x.x.x.x/32" }

#see https://github.com/andymotta/vpc-in-a-box to create vpc
variable "vpc-cidr" { default = "10.0.0.0/16" }

# aws network stuff
variable "region" { default = "us-west-2" }

variable "azs" { default = "us-west-2a,us-west-2b,us-west-2c" }

variable "MasterIPazA" { default = "10.0.1.100" }
variable "MasterIPazB" { default = "10.0.2.100" }
variable "MasterIPazC" { default = "10.0.3.100" }

variable "vpc" { default="vpc-xxxxxxxx" }
variable "public_subnets" { default = "subnet-xxxxxxxx,subnet-xxxxxxxx,subnet-xxxxxxxx" }
variable "private_subnets" { default = "subnet-xxxxxxxx,subnet-xxxxxxxx,subnet-xxxxxxxx" }

variable "master_instance_size" { default = "t2.small" }
variable "worker_instance_size" { default = "t2.medium" }
variable "sshuttle_instance_size" { default = "t2.medium" }
variable "num_workers" { default = 3 }
variable "num_priv_workers" { default = 2 }

variable "coreos_amis" {
  default = {
    us-west-2 = "ami-32a85152"
    us-east-1 = "ami-6160910c"
  }
}

variable "sshuttle_amis" {
  default = {
    us-west-2 = "ami-9abea4fb"
    us-east-1 = "ami-fce3c696"
  }
}
