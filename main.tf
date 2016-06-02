provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

resource "aws_instance" "etcd_master_1" {
    ami = "${lookup(var.coreos_amis, var.region)}"
    instance_type = "${var.master_instance_size}"
    private_ip = "${var.MasterIPazA}"
    subnet_id = "${element(split(",", var.private_subnets), 0)}"
    availability_zone = "${element(split(",", var.azs), 0)}"
    user_data       = "${file("master1-cloud-config.yml")}"
    security_groups = ["${aws_security_group.public_worker_securitygroup.id}"]
    key_name        = "${var.key_name}"
    root_block_device {
      volume_type = "gp2"
      volume_size = 50
    }
    tags {
      Name = "${var.name} etcd2 Master"
    }
    // lifecycle {
    //     prevent_destroy = "true"
    // }
}

resource "aws_instance" "etcd_master_2" {
    ami = "${lookup(var.coreos_amis, var.region)}"
    instance_type = "${var.master_instance_size}"
    private_ip = "${var.MasterIPazB}"
    subnet_id = "${element(split(",", var.private_subnets), 1)}"
    availability_zone = "${element(split(",", var.azs), 1)}"
    user_data       = "${file("master2-cloud-config.yml")}"
    security_groups = ["${aws_security_group.public_worker_securitygroup.id}"]
    key_name = "${var.key_name}"
    root_block_device {
      volume_type = "gp2"
      volume_size = 50
    }
    tags {
      Name = "${var.name} etcd2 Master"
    }
    // lifecycle {
    //     prevent_destroy = "true"
    // }
}

resource "aws_instance" "etcd_master_3" {
    ami = "${lookup(var.coreos_amis, var.region)}"
    instance_type = "${var.master_instance_size}"
    private_ip = "${var.MasterIPazC}"
    subnet_id = "${element(split(",", var.private_subnets), 2)}"
    availability_zone = "${element(split(",", var.azs), 2)}"
    user_data       = "${file("master3-cloud-config.yml")}"
    security_groups = ["${aws_security_group.public_worker_securitygroup.id}"]
    key_name        = "${var.key_name}"
    root_block_device {
      volume_type = "gp2"
      volume_size = 50
    }
    tags {
       Name = "${var.name} etcd2 Master"
    }
    // lifecycle {
    //     prevent_destroy = "true"
    // }
}

resource "aws_autoscaling_group" "public_worker_autoscale" {
  load_balancers       = ["${aws_elb.public-worker-elb.id}"]
  vpc_zone_identifier  = ["${split(",", var.public_subnets)}"]
  availability_zones   = ["${split(",", var.azs)}"]
  name                 = "public_worker_autoscale"
  min_size             = 0
  max_size             = 95
  desired_capacity     = "${var.num_workers}"
  launch_configuration = "${aws_launch_configuration.public_worker_launchconfig.name}"
  tag {
    key = "Name"
    value = "${var.name}-t2-medium"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "public_worker_launchconfig" {
  name            = "worker_config"
  image_id        = "${lookup(var.coreos_amis, var.region)}"
  instance_type   = "${var.worker_instance_size}"
  security_groups = ["${aws_security_group.public_worker_securitygroup.id}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("public-worker-cloud-config.yml")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }
}

resource "aws_autoscaling_group" "internal_worker_autoscale" {
  load_balancers       = ["${aws_elb.internal-worker-elb.id}","${aws_elb.FleetUI-elb.id}"]
  vpc_zone_identifier  = ["${split(",", var.private_subnets)}"]
  availability_zones   = ["${split(",", var.azs)}"]
  name                 = "internal_worker_autoscale"
  min_size             = 0
  max_size             = 25
  desired_capacity     = "${var.num_priv_workers}"
  launch_configuration = "${aws_launch_configuration.internal_worker_launchconfig.name}"
  tag {
    key = "Name"
    value = "${var.name}-Private-t2-medium"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "internal_worker_launchconfig" {
  name            = "internal_worker_config"
  image_id        = "${lookup(var.coreos_amis, var.region)}"
  instance_type   = "${var.worker_instance_size}"
  security_groups = ["${aws_security_group.public_worker_securitygroup.id}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("internal-worker-cloud-config.yml")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }
}

resource "aws_security_group" "public_worker_securitygroup" {
  name          = "public_worker_securitygroup"
  description   = "Security Group for Public Fleet Instances"
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
    security_groups = ["${aws_security_group.public_worker_elb_securitygroup.id}"]
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

resource "aws_security_group" "public_worker_elb_securitygroup" {
  name          = "public_worker_elb_securitygroup"
  description   = "Public Security Group for Fleet Worker ELB"
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

resource "aws_security_group" "internal_worker_elb_securitygroup" {
  name          = "internal_worker_elb_securitygroup"
  description   = "Security Group for Fleet Internal ELB"
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

resource "aws_elb" "public-worker-elb" {
  name                 = "public-worker-elb"
  security_groups      = ["${aws_security_group.public_worker_elb_securitygroup.id}"]
  internal             = false
  subnets              = ["${split(",", var.public_subnets)}"]
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

resource "aws_elb" "internal-worker-elb" {
  name                 = "internal-worker-elb"
  security_groups      = ["${aws_security_group.internal_worker_elb_securitygroup.id}"]
  internal             = true
  subnets              = ["${split(",", var.private_subnets)}"]
  listener {
    lb_port            = 80
    instance_port      = 80
    lb_protocol        = "tcp"
    instance_protocol  = "tcp"
  }
  listener {
    lb_port            = 2222
    instance_port      = 22
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

resource "aws_elb" "FleetUI-elb" {
  name                 = "FleetUI-elb"
  security_groups      = ["${aws_security_group.internal_worker_elb_securitygroup.id}"]
  internal             = true
  subnets              = ["${split(",", var.private_subnets)}"]
  listener {
    lb_port            = 80
    instance_port      = 3000
    lb_protocol        = "tcp"
    instance_protocol  = "tcp"
  }
  instances = ["${aws_instance.etcd_master_1.id}","${aws_instance.etcd_master_3.id}","${aws_instance.etcd_master_3.id}"]
  health_check {
    target              = "TCP:3000"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 25
    interval            = 30
  }
}

resource "aws_elb" "etcd-browser-elb" {
  name                 = "etcd-browser-elb"
  security_groups      = ["${aws_security_group.internal_worker_elb_securitygroup.id}"]
  internal             = true
  subnets              = ["${split(",", var.private_subnets)}"]
  listener {
    lb_port            = 80
    instance_port      = 8000
    lb_protocol        = "tcp"
    instance_protocol  = "tcp"
  }
  instances = ["${aws_instance.etcd_master_1.id}","${aws_instance.etcd_master_3.id}","${aws_instance.etcd_master_3.id}"]
  health_check {
    target              = "TCP:8000"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 25
    interval            = 30
  }
}

resource "aws_instance" "deploy" {
    depends_on = ["aws_autoscaling_group.internal_worker_autoscale"]
    ami = "${lookup(var.coreos_amis, var.region)}"
    instance_type = "${var.master_instance_size}"
    subnet_id = "${element(split(",", var.public_subnets), 2)}"
    availability_zone = "${element(split(",", var.azs), 2)}"
    user_data       = "${file("public-worker-cloud-config.yml")}"
    security_groups = ["${aws_security_group.public_worker_securitygroup.id}"]
    key_name        = "${var.key_name}"
    instance_initiated_shutdown_behavior = "terminate"
    root_block_device {
      volume_type = "gp2"
      volume_size = 50
    }
    tags {
      Name = "${var.name} deploy"
    }
    #Fleetui journal does not work without private key access
    provisioner "file" {
        source = "${var.key_file}"
        destination = "${var.key_file}"
        connection {
            user = "core"
            key_file = "${var.key_file}"
        }
    }
    provisioner "remote-exec" {
        inline = [
          "git clone https://github.com/andymotta/fleet-unit-files.git",
          "chmod 0600 ${var.key_file}",
          "touch ~/.ssh/config && echo -e 'StrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null' >> ~/.ssh/config",
          "scp -i ${var.key_file} ${var.key_file} core@${aws_instance.etcd_master_1.private_ip}:/home/core/.ssh/id_rsa",
          "scp -i ${var.key_file} ${var.key_file} core@${aws_instance.etcd_master_2.private_ip}:/home/core/.ssh/id_rsa",
          "scp -i ${var.key_file} ${var.key_file} core@${aws_instance.etcd_master_3.private_ip}:/home/core/.ssh/id_rsa",
          "sleep 30",
          "cd ~/fleet-unit-files/",
          "fleetctl start swapon.service",
          "fleetctl start fleetui@{1..2}.service",
          "fleetctl start etcd-browser.service",
          "sudo poweroff"
        ]
        connection {
          user = "core"
          key_file = "${var.key_file}"
        }
  }
}

resource "aws_instance" "sshuttle" {
    depends_on = ["aws_autoscaling_group.internal_worker_autoscale"]
    ami = "${lookup(var.sshuttle_amis, var.region)}"
    instance_type = "${var.sshuttle_instance_size}"
    subnet_id = "${element(split(",", var.public_subnets), 1)}"
    availability_zone = "${element(split(",", var.azs), 1)}"
    security_groups = ["${aws_security_group.public_worker_securitygroup.id}"]
    key_name        = "${var.key_name}"
    root_block_device {
      volume_type = "gp2"
      volume_size = 30
    }
    tags {
      Name = "${var.name} sshuttle (VPN)"
    }
}
