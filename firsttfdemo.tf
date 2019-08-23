provider "aws" {
	access_key = "${var.access_key}"
	secret_key = "${var.secret_key}"
	region = "${var.region}"
}

resource "aws_instance" "vinoterraform" {
	ami = "ami-064c88bc6887e7340"
	key_name = "${aws_key_pair.vinotfkey.id}"
	tags = {
			Name = "VinoInstance"
		}
	instance_type = "t2.micro"
	vpc_security_group_ids = ["${aws_security_group.vinotfsecgroup.id}"]

	provisioner "local-exec" {
		when = "destroy"
		command = "echo ${aws_instance.vinoterraform.public_ip}>sample.txt"
	}
	provisioner "chef" {
		connection {
			host = "${self.public_ip}"
			type = "ssh"
			user = "ubuntu"
			private_key = "${file("C:\\Vino\\VinoSampleProject\\mykey.pem")}"
		}
		client_options = [ "chef_license 'accept'" ]
		run_list = ["test_cookbook::default"]
		recreate_client = true
		node_name = "tfvino.acc.com"
		server_url = "https://manage.chef.io/organizations/vinogeetha"
		user_name = "vinovengat"
		user_key = "${file("C:\\chef-starter\\chef-repo\\.chef\\vinovengat.pem")}"
		ssl_verify_mode = ":verify_none"
	}


}
resource "aws_key_pair" "vinotfkey"{
	key_name = "vinokeypair"
	public_key = "${file("C:\\Vino\\VinoSampleProject\\mykey.pub")}"

}

output "VinoPublicIp"{
	value = "${aws_instance.vinoterraform.public_ip}"
}

resource "aws_security_group" "vinotfsecgroup"{
	name = "vinosecgroup"
	description = "to allo traffic"

	ingress  {
		from_port = "0"
		to_port = "0"
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress  {
		from_port = "0"
		to_port = "0"
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_eip" "vinoeip" {

	tags = {
			Name = "vinoelasticip"
		}
		instance = "${aws_instance.vinoterraform.id}"
	

}


