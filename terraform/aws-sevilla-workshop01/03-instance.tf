/*
  Security group: https://www.terraform.io/docs/providers/aws/r/security_group.html
*/

resource "aws_security_group" "terraform-workshop-sg" {
  name   = "terraform-workshop-sg"
  // Recuerda enlazarla con la VPC
  // Referenciamos el ID de los resources con el formato (resource).(nombre_que_le_pusiste).(propiedad) sin comillas
  vpc_id = aws_vpc.terraform-workshop-vpc.id

  //Acceder solo desde el 80 en las IPs marcadas
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  //Que pueda salir a cualquiera
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  // Los tags son opcionales, los ponemos para para sean faciles de categorizar.
  tags = {
    Name = "terraform-workshop-sg",
    DeployVersion = "0.1"
  }
}

/*
  EC2: https://www.terraform.io/docs/providers/aws/r/instance.html
  AMI: https://cloud-images.ubuntu.com/locator/ec2/
*/

resource "aws_instance" "terraform-workshop-ec2" {
  // Amazon Linux AMI 2018.03.0 (HVM) en eu-west-1
  ami           = "ami-0e41581acd7dedd99"
  instance_type = "t2.nano"
  // Recuerda enlazarla con el security group
  vpc_security_group_ids = [
    // Referenciamos el ID de los resources con el formato (resource).(nombre_que_le_pusiste).(propiedad) sin comillas
    aws_security_group.terraform-workshop-sg.id
  ]
  // Asociamos IP Pública
  associate_public_ip_address = true
  // Recuerda enlazarlo a la subnet
  // Referenciamos el ID de los resources con el formato (resource).(nombre_que_le_pusiste).(propiedad) sin comillas
  subnet_id                   = aws_subnet.terraform-workshop-subnet.id
  // Script de inicio para NGINX
  user_data = <<USER_DATA
#!/bin/bash
sudo apt update -y && sudo apt upgrade -y && sudo apt install nginx -y && sudo systemctl enable nginx && sudo systemctl start nginx
  USER_DATA

  tags = {
    Name = "terraform-workshop-ec2",
    DeployVersion = "0.1",
    AMISO = "ubuntu"
  }
}

output "web-ip" {
  // Haz que saque la propiedad public_ip de la instancia
  // Referenciamos el ID de los resources con el formato (resource).(nombre_que_le_pusiste).(propiedad) sin comillas
  value = aws_instance.terraform-workshop-ec2.public_ip
}