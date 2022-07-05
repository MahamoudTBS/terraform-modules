
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "lambda_ecr_arn" {
  description = "(Optional, default Scan Files ECR) ARN of the ECR used to pull the Lambda image"
  default     = "arn:aws:ecr:ca-central-1:806545929748:scan-files/module/s3-scan-object"
  type        = string
}

variable "lambda_image_uri" {
  description = "(Optional, default Scan Files ECR latest Docker image) The URI of the Lambda image"
  default     = "806545929748.dkr.ecr.ca-central-1.amazonaws.com/scan-files/module/s3-scan-object:577be5f7a30423539c1d5775a574e7fc5f82da31"
  type        = string
}

variable "product_name" {
  description = "(Required) Name of the product using the module"
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z\\-_]+$", var.product_name))
    error_message = "The product name can only container alphanumeric characters, hyphens, and underscores."
  }
}

variable "s3_upload_bucket_create" {
  description = "(Optional, default 'true') Create an S3 bucket to upload files to."
  type        = bool
  default     = true
}

variable "s3_upload_bucket_name" {
  description = "(Optional, default null) Name of the S3 upload bucket to scan objects in.  If `s3_upload_bucket_create` is `false` this must be an existing bucket in the account."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^[0-9a-z\\-\\.]{3,63}$", var.s3_upload_bucket_name))
    error_message = "The S3 bucket name can only container lowercase alphanumeric characters, hyphens, and periods."
  }
}

variable "s3_upload_bucket_policy_create" {
  description = "(Optional, defaut 'true') Create the S3 upload bucket policy to allow Scan Files access."
  type        = bool
  default     = true
}

variable "scan_files_assume_role_create" {
  description = "(Optional, default 'true') Create the IAM role that Scan Files assumes.  Defaults to `true`.  If this is set to `false`, it is assumed that the role already exists in the account."
  type        = bool
  default     = true
}

variable "scan_files_api_key_secret_arn" {
  description = "(Optional, default Scan Files secret arn) ARN of the SecretsManager secret that contains the Scan Files API key"
  type        = string
  default     = "arn:aws:secretsmanager:ca-central-1:806545929748:secret:/scan-files/api_auth_token-1tLf9T"
}

variable "scan_files_api_key_kms_arn" {
  description = "(Optional, default Scan Files KMS key arn) ARN of the KMS key used to encrypt the scan_files_api_key_secret_arn"
  type        = string
  default     = "arn:aws:kms:ca-central-1:806545929748:key/*"
}

variable "scan_files_role_arn" {
  description = "(Optional, default Scan Files API role) Scan Files lambda execution role ARN"
  default     = "arn:aws:iam::806545929748:role/scan-files-api"
  type        = string
}

variable "scan_files_url" {
  description = "(Optional, default Scan Files production URL) Scan Files URL"
  default     = "https://scan-files.alpha.canada.ca"
  type        = string
}
