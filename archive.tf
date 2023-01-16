data "archive_file" "function" {
  type        = "zip"
  source_file = "${path.module}/default-index-redirect/function.js"
  output_path = "${path.module}/default-index-redirect/function.zip"
}
