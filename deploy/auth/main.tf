locals {
  name = "${length(var.name) == 0 ? random_pet.name.id : var.name}"
}

resource "random_pet" "name" {}

resource "aws_cognito_user_pool" "main" {
  name                       = "${local.name}"
  auto_verified_attributes   = ["email"]

  email_configuration {
    reply_to_email_address = "${length(var.reply_to) == 0 ? "foo.bar@baz" : var.reply_to}"
  }

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  # lambda_config {
  #   create_auth_challenge          = "${aws_lambda_function.main.arn}"
  #   custom_message                 = "${aws_lambda_function.main.arn}"
  #   define_auth_challenge          = "${aws_lambda_function.main.arn}"
  #   post_authentication            = "${aws_lambda_function.main.arn}"
  #   post_confirmation              = "${aws_lambda_function.main.arn}"
  #   pre_authentication             = "${aws_lambda_function.main.arn}"
  #   pre_sign_up                    = "${aws_lambda_function.main.arn}"
  #   verify_auth_challenge_response = "${aws_lambda_function.main.arn}"
  # }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 3
      max_length = 254
    }
  }

  tags {
    "Name"        = "${local.name}"
    "Environment" = "${var.environment}"
  }
}
