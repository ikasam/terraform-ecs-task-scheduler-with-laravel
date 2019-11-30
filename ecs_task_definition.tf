resource "aws_ecr_repository" "inspire" {
  name                 = "inspire"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "inspire" {
  name = "inspire"
}

resource "aws_ecs_task_definition" "inspire" {
  family                   = "inspire"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions    = data.template_file.inspire_container_definitions_json.rendered
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
}

data "template_file" "inspire_container_definitions_json" {
  template = "${file("ecs_container_definitions_inspire.json")}"

  vars = {
    container_name  = "inspire"
    container_image = "${aws_ecr_repository.inspire.repository_url}:latest"
    awslogs-group   = aws_cloudwatch_log_group.inspire.name
    region          = var.region
    APP_ENV         = "development"
  }
}

resource "aws_cloudwatch_log_group" "inspire" {
  name = "/ecs/inspire"
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "ECSTaskExecutionRoleForInspire"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    sid     = "ECSTaskExecution"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
