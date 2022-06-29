data "aws_iam_role" "scan_files" {
  count = var.scan_files_assume_role_create ? 0 : 1
  name  = "ScanFilesGetObjects"
}

resource "aws_iam_role" "scan_files" {
  count              = var.scan_files_assume_role_create ? 1 : 0
  name               = "ScanFilesGetObjects"
  assume_role_policy = data.aws_iam_policy_document.scan_files_assume_role[0].json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "scan_files_assume_role" {
  count = var.scan_files_assume_role_create ? 1 : 0

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.scan_files_role_arn]
    }
  }
}

resource "aws_iam_policy" "scan_files" {
  count  = var.scan_files_assume_role_create ? 1 : 0
  name   = "ScanFilesGetObjects"
  path   = "/"
  policy = data.aws_iam_policy_document.scan_files[0].json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "scan_files" {
  count      = var.scan_files_assume_role_create ? 1 : 0
  role       = aws_iam_role.scan_files[0].name
  policy_arn = aws_iam_policy.scan_files[0].arn
}

data "aws_iam_policy_document" "scan_files" {
  count = var.scan_files_assume_role_create ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging"
    ]
    resources = [
      local.upload_bucket_arn,
      "${local.upload_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.scan_complete.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    resources = [
      aws_kms_key.sns_lambda.arn
    ]
  }
}
