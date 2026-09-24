resource "aws_lb_target_group" "blue" {
  name     = var.blue_target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = var.blue_target_group_name
    Environment = "Blue"
  }
}

resource "aws_lb_target_group" "green" {
  name     = var.green_target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = var.green_target_group_name
    Environment = "Green"
  }
}

resource "aws_launch_template" "blue" {
  name = var.blue_launch_template_name

  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    data.aws_security_group.ssh.id,
    data.aws_security_group.http.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx

    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>Blue Environment</title>
    </head>
    <body>
      <h1>Blue Environment</h1>
    </body>
    </html>
    HTML
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "cmtr-7zh97qyv-blue-instance"
      Environment = "Blue"
    }
  }

  tags = {
    Name        = var.blue_launch_template_name
    Environment = "Blue"
  }
}

resource "aws_launch_template" "green" {
  name = var.green_launch_template_name

  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    data.aws_security_group.ssh.id,
    data.aws_security_group.http.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx

    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>Green Environment</title>
    </head>
    <body>
      <h1>Green Environment</h1>
    </body>
    </html>
    HTML
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "cmtr-7zh97qyv-green-instance"
      Environment = "Green"
    }
  }

  tags = {
    Name        = var.green_launch_template_name
    Environment = "Green"
  }
}

resource "aws_autoscaling_group" "blue" {
  name = var.blue_asg_name

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  vpc_zone_identifier = [
    data.aws_subnet.public1.id,
    data.aws_subnet.public2.id
  ]

  target_group_arns = [
    aws_lb_target_group.blue.arn
  ]

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "cmtr-7zh97qyv-blue-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "green" {
  name = var.green_asg_name

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  vpc_zone_identifier = [
    data.aws_subnet.public1.id,
    data.aws_subnet.public2.id
  ]

  target_group_arns = [
    aws_lb_target_group.green.arn
  ]

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "cmtr-7zh97qyv-green-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Green"
    propagate_at_launch = true
  }
}

resource "aws_lb" "main" {
  name               = var.load_balancer_name
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    data.aws_security_group.lb.id
  ]

  subnets = [
    data.aws_subnet.public1.id,
    data.aws_subnet.public2.id
  ]

  tags = {
    Name = var.load_balancer_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = var.blue_weight
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = var.green_weight
      }
    }
  }

  tags = {
    Name = "cmtr-7zh97qyv-http-listener"
  }
}