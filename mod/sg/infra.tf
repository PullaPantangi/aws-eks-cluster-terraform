resource "aws_security_group" "platinum_sg1" {
  vpc_id = var.vpc_id 
  dynamic "ingress" {
    for_each = toset(var.ports_in)
    content {
      cidr_blocks = [var.igw_route]
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "TCP"
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}