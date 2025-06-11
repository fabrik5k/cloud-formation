# asg.tf

resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    security_groups = [aws_security_group.web.id]
    subnet_id        = module.vpc.public_subnet_ids[0]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash -xe
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Servidor Web em ambiente ${var.environment}</h1>" > /var/www/html/index.html
    EOF
    )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.environment}-web" })
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.environment}-asg"
  launch_template {
    id      = aws_launch_template.web.id
    version = "$${aws_launch_template.web.latest_version}"
  }
  vpc_zone_identifier       = module.vpc.public_subnet_ids
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.environment}-web"
    propagate_at_launch = true
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

