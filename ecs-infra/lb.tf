# Create a Security Group for the Application Load Balancer
resource "aws_security_group" "fluent_bit_alb_sg" {
  name        = "fluent-bit-alb-sg"
  description = "Controls access to the ALB"
  vpc_id      = aws_vpc.fluent_bit_vpc.id

  ingress {
    protocol    = "TCP"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the Application Load Balancer
resource "aws_alb" "fluent_bit_alb" {
  name            = "fluent-bit-alb"
  subnets         = aws_subnet.fluent_bit_public_subnet[*].id
  security_groups = [aws_security_group.fluent_bit_alb_sg.id]
}

# Create a HTTP target group for the nginx service
resource "aws_alb_target_group" "fluent_bit_tg" {
  name        = "fluent-bit-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fluent_bit_vpc.id
  target_type = "ip"
}

# Redirect all traffic from the Application Load Balancer to the Target Group
resource "aws_alb_listener" "fluent_bit_listener" {
  load_balancer_arn = aws_alb.fluent_bit_alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.fluent_bit_tg.id
    type             = "forward"
  }
}