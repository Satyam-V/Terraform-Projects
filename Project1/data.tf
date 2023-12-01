data "aws_availability_zones" "available_1" {
  state = "available"
}
data "aws_ami" "ubuntu" {
  most_recent = true
}