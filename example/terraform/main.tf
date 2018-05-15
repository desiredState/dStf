provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_instance" "example" {
  ami           = "ami-403e2524"
  instance_type = "t2.micro"
}
