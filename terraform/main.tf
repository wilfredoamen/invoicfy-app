provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "invoify_sg" {
  name        = "invoify-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

resource "aws_instance" "invoify" {
  ami                         = "ami-0c94855ba95c71c99"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.invoify_sg.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io docker-compose",
      "sudo usermod -aG docker ubuntu",
      "newgrp docker"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "InvoifyServer"
  }
}
