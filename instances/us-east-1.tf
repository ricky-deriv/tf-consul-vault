provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

data "aws_ami" "aws_linux" {
    most_recent = true
    owners = ["137112412989"]

    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "sandbox_key" {
    key_name    = "sandbox-key"
    public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD76emokDlJ597w+hFWC+UyHsywzPwiOsnjFamcKDBo5i+UZC3zZneXS0eWo2cYYHni+yJ6ITsqRiezxVVkMcauf+eB43h4xmleNuwOGBZL1l58YmuL4YKT9U25wyROyRoQDMcw4pBxtiBLQ93AcFXPKxUtdydzOoSmSpqmTWT82vL7GU16tdUrUZRav1ug+7DKCn5hmCJoQ5EYFeudzI39h4ZvP2x7ciythUy13/fe1OME3TnIEr2bAYBhq7V9DIPSjHlY6Gqh/PRzdGAyi7FJgwRV4xSZphI7hDJFljujAdljDJbNJYf2Pqu+DPpsdOkkkFWez7bOZljP4xb66K4tsfs5qJK0XG8HdKFkzMqOKN/e0hmXwAyoZdDjqF5v4oNQbPRvZlaCWfcX8reJgcpDD8tLjJnX/N3T301WtQsBiadSZO+bw/cGjk4H6RM/0tV5P11HF7o4eOUzg0+Q9rXdBxHzaTNBcNtfMFAXHCstdaRdM67CHpRgnh2bCH50Ljc= sandbox-key"
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

resource "aws_instance" "host01" {
    ami             = data.aws_ami.aws_linux.id
    instance_type   = "t2.micro"
    key_name        = aws_key_pair.sandbox_key.key_name
    security_groups = [aws_security_group.allow_tls.name]

    tags = {
        Name = "host01"
    }

    user_data = "${file("scripts/initial_config.sh")}"
    user_data_replace_on_change = true
}
