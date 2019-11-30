resource "aws_cloudwatch_event_rule" "inspire_every_minutes" {
  description         = "run php artisan inspire every minutes"
  is_enabled          = true
  name                = "inspire_every_minutes"
  schedule_expression = "cron(* * * * ? *)"
}

data "template_file" "php_artisan_inspire" {
  template = file("ecs_container_overrides.json")

  vars = {
    container_name = "inspire"
    command        = "inspire"
  }
}

resource "aws_cloudwatch_event_target" "inspire" {
  rule      = aws_cloudwatch_event_rule.inspire_every_minutes.name
  arn       = aws_ecs_cluster.inspire.arn
  target_id = "inspire"
  role_arn  = aws_iam_role.ecs_events_run_task.arn
  input     = data.template_file.php_artisan_inspire.rendered
  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = replace(aws_ecs_task_definition.inspire.arn, "/:[0-9]+$/", "")
    network_configuration {
      assign_public_ip = true
      security_groups  = [aws_vpc.inspire.default_security_group_id]
      subnets          = [aws_subnet.inspire.id]
    }
  }
}

data "aws_iam_policy_document" "events_assume_role" {
  statement {
    sid     = "CloudWatchEvents"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_events_run_task" {
  name               = "ECSEventsRunTask"
  assume_role_policy = data.aws_iam_policy_document.events_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_events_run_task" {
  role       = aws_iam_role.ecs_events_run_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_vpc" "inspire" {
  cidr_block = "192.168.200.0/24"
  tags = {
    Name = "inspire"
  }
}

resource "aws_subnet" "inspire" {
  vpc_id     = aws_vpc.inspire.id
  cidr_block = "192.168.200.0/24"
  tags = {
    Name = "inspire"
  }
}

resource "aws_internet_gateway" "inspire" {
  vpc_id = aws_vpc.inspire.id
  tags = {
    Name = "inspire"
  }
}

resource "aws_default_route_table" "r" {
  default_route_table_id = aws_vpc.inspire.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inspire.id
  }
}
