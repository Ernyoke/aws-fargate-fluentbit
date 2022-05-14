# Allow traffic from the Application Load Balancer to the ECS task
resource "aws_security_group" "fluent_bit_task_sg" {
  name        = "fluent-bit-task-sg"
  description = "Allow inbound access from the ALB only"
  vpc_id      = aws_vpc.fluent_bit_vpc.id

  ingress {
    protocol        = "TCP"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.fluent_bit_alb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "fluentbit_cluster" {
  name = "fluent-bit-ecs-cluster"
}

resource "aws_ecs_task_definition" "nginx_fluent_bit" {
  family                   = "nginx-fluent-bit"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = templatefile("task.tftpl", {
    fargate_cpu    = var.cpu
    fargate_memory = var.memory
    app_image      = var.img
    port           = var.container_port
    aws_region     = var.aws_region
  })

  execution_role_arn = aws_iam_role.fluent_bit_task_role.arn
  task_role_arn      = aws_iam_role.fluent_bit_task_role.arn
}

resource "aws_ecs_service" "fluent_bit_service" {
  name            = "fluent-bit-service"
  cluster         = aws_ecs_cluster.fluentbit_cluster.id
  task_definition = aws_ecs_task_definition.nginx_fluent_bit.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.fluent_bit_task_sg.id]
    subnets         = aws_subnet.fluent_bit_private_subnet[*].id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.fluent_bit_tg.id
    container_name   = "nginx-fluentbit"
    container_port   = var.container_port
  }

  depends_on = [aws_alb_listener.fluent_bit_listener]
}

resource "aws_iam_role" "fluent_bit_task_role" {
  name = "fluent-bit-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "fluent_bit_task_policy_general" {
  name        = "fluent_bit_task_policy_general"
  path        = "/"
  description = "Task policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "fluent_bit_task_policy_s3_write" {
  name        = "fluent_bit_task_policy_allow_s3_write"
  path        = "/"
  description = "Task policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${aws_s3_bucket.fluentbit_logging_bucket.bucket}/*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit_task_role_general_attachment" {
  role       = aws_iam_role.fluent_bit_task_role.id
  policy_arn = aws_iam_policy.fluent_bit_task_policy_general.arn
}

resource "aws_iam_role_policy_attachment" "fluent_bit_task_role_s3_write_attachment" {
  role       = aws_iam_role.fluent_bit_task_role.id
  policy_arn = aws_iam_policy.fluent_bit_task_policy_s3_write.arn
}