resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "publicsub1" {
  vpc_id                  = aws_vpc.myvpc.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "publicsub2" {
  vpc_id                  = aws_vpc.myvpc.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "rtassociation1" {
  route_table_id = aws_route_table.RT.id
  subnet_id      = aws_subnet.publicsub1.id
}

resource "aws_route_table_association" "rtassociation2" {
  route_table_id = aws_route_table.RT.id
  subnet_id      = aws_subnet.publicsub2.id
}


resource "aws_security_group" "mysg" {
  vpc_id      = aws_vpc.myvpc.id
  name        = "Security group"
  description = "Inbounda and outbound rules for sg"

  ingress {
    description = "Allow http"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }
}

resource "aws_instance" "mywebserver1" {
  ami                    = "ami-04a81a99f5ec58529"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.publicsub1.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "mywebserver2" {
  ami                    = "ami-04a81a99f5ec58529"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.publicsub2.id
  user_data              = base64encode(file("userdata1.sh"))
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.mysg.id]
  subnets         = [aws_subnet.publicsub1.id, aws_subnet.publicsub2.id]
}

resource "aws_alb_target_group" "tg" {
  name     = "mytg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "tgattachment1" {
  target_group_arn = aws_alb_target_group.tg.arn
  port             = 80
  target_id        = aws_instance.mywebserver1.id
}

resource "aws_lb_target_group_attachment" "tgattachment2" {
  target_group_arn = aws_alb_target_group.tg.arn
  port             = 80
  target_id        = aws_instance.mywebserver2.id
}

resource "aws_lb_listener" "alblistener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.alb.dns_name
}