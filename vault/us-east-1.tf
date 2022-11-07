provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_key_pair" "sandbox_key" {
    key_name    = "sandbox-key"
    public_key  = var.general_public_key
}

resource "aws_security_group" "allow_tls" {
    name        = "allow_tls"
    description = "allow tls inbound traffic"

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "vault_server_01" {
    ami             = data.aws_ami.aws_linux.id
    instance_type   = "t2.micro"
    key_name        = aws_key_pair.sandbox_key.key_name
    security_groups = [aws_security_group.allow_tls.name]

    tags = {
        Name = "vault-server-01"
    }

    user_data = "${file("scripts/initial_config.sh")}"
    user_data_replace_on_change = true
}

resource "aws_instance" "client-01" {
    ami             = data.aws_ami.aws_linux.id
    instance_type   = "t2.micro"
    key_name        = aws_key_pair.sandbox_key.key_name
    security_groups = [aws_security_group.allow_tls.name]

    tags = {
        Name = "client-01"
    }

    user_data = "${file("scripts/client_config.sh")}"
    user_data_replace_on_change = true

    depends_on = [ aws_instance.vault_server_01 ]
}