provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

resource "aws_instance" "etcd_master_1" {
    ami = "${lookup(var.coreos_amis, var.region)}"
    availability_zone  = "${var.az1}"
    instance_type = "${var.master_instance_size}"
    subnet_id = "${var.subnet1}"
    private_ip = "${var.MasterIPaz1}"
    user_data       = "${file("ui-master1-cloud-config.yml")}"
    security_groups = ["${aws_security_group.FleetCluster_public_securitygroup.id}"]
    key_name        = "${var.key_name}"
    root_block_device {
      volume_type = "gp2"
      volume_size = 50
    }
    provisioner "file" {
        source = "${var.dockercfg}"
        destination = "/home/core/.dockercfg"
        connection {
            user = "core"
            key_file = "${var.key_file}"
        }
    }
    #Fleetui journal does not work without key access
    provisioner "file" {
        source = "${var.key_file}"
        destination = "/home/core/.ssh/id_rsa"
        connection {
            user = "core"
            key_file = "${var.key_file}"
        }
    }
    tags {
      Name = "${var.name} etcd2 FleetUI Master"
    }
}

resource "aws_instance" "etcd_master_2" {
    ami = "${lookup(var.coreos_amis, var.region)}"
    availability_zone  = "${var.az2}"
    instance_type = "${var.master_instance_size}"
    subnet_id = "${var.subnet2}"
    private_ip = "${var.MasterIPaz2}"
    user_data       = "${file("master2-cloud-config.yml")}"
    security_groups = ["${aws_security_group.FleetCluster_public_securitygroup.id}"]
    key_name        = "${var.key_name}"
    root_block_device {
      volume_type = "gp2"
      volume_size = 50
    }
    provisioner "file" {
        source = "${var.dockercfg}"
        destination = "/home/core/.dockercfg"
        connection {
            user = "core"
            key_file = "${var.key_file}"
        }
    }
    tags {
      Name = "${var.name} etcd2 Master"
    }
}

resource "aws_instance" "etcd_master_3" {
    ami = "${lookup(var.coreos_amis, var.region)}"
    availability_zone  = "${var.az3}"
    instance_type = "${var.master_instance_size}"
    subnet_id = "${var.subnet3}"
    private_ip = "${var.MasterIPaz3}"
    user_data       = "${file("master3-cloud-config.yml")}"
    security_groups = ["${aws_security_group.FleetCluster_public_securitygroup.id}"]
    key_name        = "${var.key_name}"
    root_block_device {
      volume_type = "gp2"
      volume_size = 50
    }
    provisioner "file" {
        source = "${var.dockercfg}"
        destination = "/home/core/.dockercfg"
        connection {
            user = "core"
            key_file = "${var.key_file}"
        }
    }
    tags {
       Name = "${var.name} etcd2 Master"
    }
}

resource "aws_autoscaling_group" "FleetCluster_worker_autoscale" {
  load_balancers       = ["${aws_elb.FleetCluster-worker-elb.id}"]
  vpc_zone_identifier  = ["${element(split(",", var.public_subnets), count.index)}"]
  availability_zones   = ["${element(split(",", var.azs), count.index)}"]
  name                 = "FleetCluster_worker_autoscale"
  min_size             = 0
  max_size             = 95
  desired_capacity     = "${var.num_workers}"
  launch_configuration = "${aws_launch_configuration.FleetCluster_worker_launchconfig.name}"
  tag {
    key = "Name"
    value = "${var.name}-t2-medium"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "FleetCluster_worker_launchconfig" {
  name            = "FleetCluster_worker_config"
  image_id        = "${lookup(var.coreos_amis, var.region)}"
  instance_type   = "${var.worker_instance_size}"
  security_groups = ["${aws_security_group.FleetCluster_public_securitygroup.id}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("worker-cloud-config.yml")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }
}

resource "aws_autoscaling_group" "FleetCluster_priv_worker_autoscale" {
  load_balancers       = ["${aws_elb.FleetCluster-internal-elb.id}"]
  vpc_zone_identifier  = ["${element(split(",", var.private_subnets), count.index)}"]
  availability_zones   = ["${element(split(",", var.azs), count.index)}"]
  name                 = "FleetCluster_priv_worker_autoscale"
  min_size             = 0
  max_size             = 25
  desired_capacity     = "${var.num_priv_workers}"
  launch_configuration = "${aws_launch_configuration.FleetCluster_priv_worker_launchconfig.name}"
  tag {
    key = "Name"
    value = "${var.name}-Private-t2-medium"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "FleetCluster_priv_worker_launchconfig" {
  name            = "FleetCluster_priv_worker_config"
  image_id        = "${lookup(var.coreos_amis, var.region)}"
  instance_type   = "${var.worker_instance_size}"
  security_groups = ["${aws_security_group.FleetCluster_public_securitygroup.id}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("priv-worker-cloud-config.yml")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }
}

resource "aws_security_group" "FleetCluster_public_securitygroup" {
  name          = "FleetCluster_public_securitygroup"
  description   = "Public Security Group for FleetCluster Instances"
  vpc_id        = "${var.vpc}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.yourPubIP}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    security_groups = ["${aws_security_group.elb_securitygroup.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc-cidr}"]
  }

  ingress {
    from_port   = 32768
    to_port     = 61000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 32768
    to_port     = 61000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_securitygroup" {
  name          = "FleetCluster_elb_securitygroup"
  description   = "Public Security Group for FleetCluster ELB"
  vpc_id        = "${var.vpc}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_elb_securitygroup" {
  name          = "FleetCluster_internal_elb_securitygroup"
  description   = "Private Security Group for FleetCluster Internal ELB"
  vpc_id        = "${var.vpc}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.yourPubIP}"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc-cidr}"]
  }
}

resource "aws_elb" "FleetCluster-worker-elb" {
  name                 = "FleetCluster-worker-elb"
  security_groups      = ["${aws_security_group.elb_securitygroup.id}"]
  internal             = false
  subnets              = ["${element(split(",", var.public_subnets), count.index)}"]

  listener {
    lb_port            = 80
    instance_port      = 80
    lb_protocol        = "tcp"
    instance_protocol  = "tcp"
  }

  health_check {
    target              = "TCP:80"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 25
    interval            = 30
  }
}

resource "aws_elb" "FleetCluster-internal-elb" {
  name                 = "FleetCluster-internal-elb"
  security_groups      = ["${aws_security_group.internal_elb_securitygroup.id}"]
  internal             = true
  subnets              = ["${element(split(",", var.private_subnets), count.index)}"]

  listener {
    lb_port            = 80
    instance_port      = 80
    lb_protocol        = "tcp"
    instance_protocol  = "tcp"
  }

  health_check {
    target              = "TCP:80"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 25
    interval            = 30
  }
}
