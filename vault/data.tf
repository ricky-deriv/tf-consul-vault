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