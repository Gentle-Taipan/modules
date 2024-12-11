data "aws_ami" "latest_ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


data "aws_subnet" "web" {
  id = var.subnet_id
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = var.subnet_id
  user_data              = <<EOF
  yum -y update
  yum -y install httpd
  my_ip = "192.168.1.1"
  cat <<HTMLTEXT > /var/www/html/index.html
  <h2>
  ${var.name} webserver with IP : $my_ip <br>
  ${var.name} webserver in AZ : ${data.aws_subnet.web.availability_zone}<br>
  Message : </h2>${var.message}
  service httpd start
  systemctl enable httpd
  EOF
  tags = {
    Name  = "${var.name}-webserver-${var.subnet_id}"
    Owner = "Suhail"
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.name} webserver SG-"
  vpc_id      = data.aws_subnet.web.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.name}-webserver-sg"
    Owner = "Suhail"
  }
}
