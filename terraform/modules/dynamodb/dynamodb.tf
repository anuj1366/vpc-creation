resource "aws_dynamodb_table" "vpc_table" {
  name         = var.dynamodb_name
  billing_mode = var.billing_mode
  range_key = var.range_key
  hash_key = var.hash_key
    
  attribute {
    name = var.attributes["name"]
    type = var.attributes["type"]
    
  }

  dynamic "attribute" {
    for_each = var.range_key != null ? [var.range_key] : []

    content {
      name =  attribute.value
      type =  "S"
    }
  }
  server_side_encryption {
        enabled = var.server_side_encryption
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = var.dynamodb_name,
      environment = var.env
    }
  )
}