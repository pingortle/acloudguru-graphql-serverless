variable "stage" {}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "${var.stage}-shortened-urls"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "slug"

  attribute {
    name = "slug"
    type = "S"
  }

  tags {
    Name        = "${var.stage}-shortened-urls"
    Environment = "${var.stage}"
  }
}
