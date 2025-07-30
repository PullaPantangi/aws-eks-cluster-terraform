resource "aws_lb" "dev" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.sub_id

  enable_deletion_protection = true
  depends_on = [ var.pub_instance ]
}
resource "aws_lb_target_group" "dev" {
  name     = "dev-ui-target-group"
  port     = 80
  protocol = "HTTP" 
  vpc_id   = var.vpc_id
  health_check {
   protocol = "HTTP"
   port = 80
   path = "/"
}
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.dev.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.dev.arn
    }
  depends_on = [aws_lb.dev] 
}

resource "aws_lb_target_group_attachment" "dev" {
  count            = length(var.inttance_id)  
  target_group_arn = aws_lb_target_group.dev.arn
  target_id        = element(var.inttance_id, count.index)
  port             = 80
    depends_on = [aws_lb_listener.front_end, aws_lb_target_group.dev]
}
