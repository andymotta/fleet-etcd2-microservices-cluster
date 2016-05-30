# aws creds
variable "access_key" {}
variable "secret_key" {}
variable "key_name" {}

variable "name" { default = "fleet-demo" }

variable "key_file" { default = "~/.ssh/aws.pem" }
variable "dockercfg" { default = "~/.dockercfg" }

variable "yourPubIP" { default = "70.0.0.0/32" }

#see https://github.com/andymotta/vpc-in-a-box to create vpc
variable "vpc-cidr" { default = "10.0.0.0/16" }

# aws network stuff
variable "region" { default = "us-west-2" }

variable "azs" { default = "us-west-2a,us-west-2b,us-west-2c" }

variable "MasterIPaz1" { default = "10.0.101.100" }
variable "MasterIPaz2" { default = "10.0.102.100" }
variable "MasterIPaz3" { default = "10.0.103.100" }
#ridic workaround for master nodes
variable "az1" { default = "us-west-2a" }
variable "az2" { default = "us-west-2b" }
variable "az3" { default = "us-west-2c" }
variable "subnet1" { default="subnet-xxxxxxxx" }
variable "subnet2" { default="subnet-xxxxxxxx" }
variable "subnet3" { default="subnet-xxxxxxxx" }


variable "vpc" { default="vpc-xxxxxxxx" }
variable "public_subnets" { default = "subnet-xxxxxxxx,subnet-xxxxxxxx,subnet-xxxxxxxx" }
variable "private_subnets" { default = "subnet-xxxxxxxx,subnet-xxxxxxxx,subnet-xxxxxxxx" }

variable "master_instance_size" { default = "t2.small" }
variable "worker_instance_size" { default = "t2.medium" }
variable "num_workers" { default = 4 }
variable "num_priv_workers" { default = 2 }

variable "coreos_amis" {
  default = {
    us-east-1 = "ami-6160910c"
    us-west-2 = "ami-32a85152"
  }
}
