output "aws_ecr_url" {
  value = "${aws_ecr_repository.inspire.repository_url}:latest"
}
