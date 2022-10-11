resource "aws_iam_role_policy" "ec2_policy" {
  name = var.env_code
  role = aws_iam_role.ec2-policy.id

  policy = file("s3-policy.json")
}

resource "aws_iam_role" "ec2-policy" {
  name               = var.env_code
  assume_role_policy = file("s3-role.json")
}

resource "aws_iam_instance_profile" "main" {
  name = var.env_code
  role = aws_iam_role.ec2-policy.name
}

