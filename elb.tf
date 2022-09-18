# TG
resource "aws_lb_target_group" "TG" {
  name     = "NLB-TG"
  port     = 80
  vpc_id   = aws_vpc.my-vpc.id
  protocol = "TCP"
}

#TGA
resource "aws_lb_target_group_attachment" "TGA" {
  count            = length(var.azs)
  port             = 80
  target_group_arn = aws_lb_target_group.TG.arn
  target_id        = element(aws_instance.Private-Server[*].id, count.index)
}

#NLB
resource "aws_lb" "NLB" {
  subnets            = [aws_subnet.Public-Subnet.0.id, aws_subnet.Public-Subnet.1.id, aws_subnet.Public-Subnet.2.id]
  load_balancer_type = "network"
  name               = "My-NLB"
}

#NLB-Listners
resource "aws_lb_listener" "NLB-listner" {
  load_balancer_arn = aws_lb.NLB.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}
