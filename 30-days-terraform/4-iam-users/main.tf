provider "aws" {
  region = var.region
  profile = var.profile
}

resource "aws_iam_user" "users" {
  for_each = {for user in local.users: user.first_name => user}
  name = "${substr(each.value.first_name, 0, 1)} ${each.value.last_name}"
  path = "/users/"

  tags = {
    "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
    "Department" = each.value.department
    "Role" = each.value.role

  }
}

resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users

  user = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [ password_reset_required, password_length ]
  }
}

resource "aws_iam_group" "management" {
  name = "Management"
  path = "/groups/"
}

resource "aws_iam_group" "analyst" {
  name = "Analyst"
  path = "/groups/"
}
resource "aws_iam_group" "developers" {
  name = "Developers"
  path = "/groups/"
}

resource "aws_iam_group_membership" "management_members" {
  name = "Management Group Members"
  group = aws_iam_group.management.name
  users = [
    for user in aws.iam_users : user.name if user.tags.Department == ["CTO", "CFO", "Manager"]
  ]
}

resource "aws_iam_group_membership" "developers_members" {
  name = "Developers Group Members"
  group = aws_iam_group.developers.name
  users = [
    for user in aws.iam_users : user.name if user.tags.Department == ["Developer"]
  ]
}
resource "aws_iam_group_membership" "analyst_members" {
  name = "Analyst Group Members"
  group = aws_iam_group.analyst.name
  users = [
    for user in aws.iam_users : user.name if user.tags.Department == ["Analyst"]
  ]
}