data "aws_caller_identity" "current" {}

data "aws_vpc" "get_vpc" {
    filter {
        name = "tag:Name"
        values = ["my-test-vpc"]
    }
}

data "aws_security_group" "get_security_group_id" {
    filter {
        name = "tag:Name"
        values = ["my-test-security-group"]
    }
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.get_vpc.id]
    }

}

variable "amiid" {
	type = string
	default = "ami-00890f614e48ce866"
}

resource "aws_instance" "bhanu_test_ec2" {
	ami = var.amiid
	instance_type = "t2.micro"
	key_name = "KeyPair-April30"
	vpc_security_group_ids = [data.aws_security_group.get_security_group_id.id]
	tags = {
		Name = "db tag"
	}
    connection {
        type = "ssh"
        user = "ec2-user"
        host = self.public_ip
        private_key = file("/home/bhanu/terraform-dir/amazon_private.key")

    }
    provisioner "remote-exec" {
    inline = [
      "sudo yum -y install tree",
      "echo hello > hello.txt"
    ]
  }	

}

output "aws_security_group_id" {
    value = data.aws_security_group.get_security_group_id.id
}

output "aws_vpc_id" {
    value = data.aws_vpc.get_vpc.id
}