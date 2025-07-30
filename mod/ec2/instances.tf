resource "aws_instance" "Pub" {
  count                       = length(var.pub_subnet_cidr)
 #ami                         = var.ami
  ami                         = lookup(var.ami, var.region)
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = element(var.pub_sub, count.index)
  availability_zone           = element(var.az, count.index)
  associate_public_ip_address = true
  tags = merge(
    var.comman_tags,
    {
      Name = "${var.Env}-pub-server-${count.index + 1}"
    }
  )
  user_data = <<-EOF
#!/bin/bash
sudo yum install git* wget nginx* -y
sudo echo "Copying the SSH Key Of Jenkins to the server"
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCPo9tb2e6PERHaf3gMG6TozhIKqNbhkR5T/5KNI3hDHO1KnIlw8or0kYoeSSMX4K00byxSn4DgOarknj4ZuINgfbmyNk81DJlTBBBHHU7duxsnHCiggFz9JhgpcyhqprLHh3EqBn9N3qRPOs9Ic7tVtXDRKtUt3P1/tJV1Jx2usBjlXa9MC6BsoOzdyauN5N/HOrslkO2KXR22sACfk5ccF/bHIKBROfiY9BEBuiCLeD6V8mRbNzb1169WuBFpQtYUofrKGEAmTJzjo957q8M/lRAOkxsxh95mgxwLi1SKamhKSB6RiutdsDopRHc18cmq560OJSCVaKEbEjQlDhXTyQ38w+2pQa4DDGC1NYOYnN4x4FNd7n0wtPfBU1dWoQvvQHWcW6t9ezuCQ3sgUoLKjlzbfDAEgn6RLGrkR7IbFdv2Ux4xuBbtG6Kc4Bp61b+xLC82XlOojDhz12kgkt3AaKJsQC4jgpicT6RI/9B4d/FLQaV4Whg8v9sMEBBFr0s= raoli@Bhuvika" >> /home/ec2-user/.ssh/authorized_keys
EOF
}
resource "null_resource" "remote_usedata" {
  count      = length(aws_instance.Pub[*].id)
  depends_on = [aws_instance.Pub]
  provisioner "file" {
    source      = "C:/Users/raoli//modules/ec2/userdata.sh"
    destination = "/home/ec2-user/userdata.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/userdata.sh",
      "sudo /home/ec2-user/userdata.sh"
    ]
  }
  connection {
    type        = "ssh"
    host        = aws_instance.Pub[count.index].public_ip
    user        = "ec2-user"
    private_key = file(var.key_path)
  }
}