resource "aws_instance" "terraform-hands-on" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "agent1"
  }
}