resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "rta2" {
  gateway_id     = aws_internet_gateway.sub2.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "websg" {
  name        = "websg"
  vpc_id      = aws_vpc.my_vpc.id

   ingress {
    from_port        = 80
    to_port          = 80
    description      = "HTTP"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }
   ingress {
    from_port        = 22
    to_port          = 22
    description      = "SSH"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }
    
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   }

}

resource "aws_s3_bucket" "example" {
  bucket = "deepakterraform2023project"
}

resource "aws_instance" "webserver1" {
  ami = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.websg.id ]
  subnet_id = aws_subnet.sub1.id
  user_data = base64decode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
  ami = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.websg.id ]
  subnet_id = aws_subnet.sub2.id
  user_data = base64decode(file("userdata1.sh"))
}

# CREATE ALB
resource "aws_lb" "myalb" {
  name = "myalb"
  internal = false
  load_balancer_type = "application"


  security_groups = [ aws_security_group.websg.id ]
  subnets = [aws_subnet.sub1.id, aws_subnet.sub2.id]

}

resource "aws_lb_target_group" "tg" {
  name = "mytg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"

  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver2.id
  port = 80
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type = "forward"

  }
}

output "loadbalacerdns" {
    value = aws_lb.myalb.dns_name
}




