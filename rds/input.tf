variable "instances" {
  description = "The number of RDS Cluster instances to create"
  type        = number
  default     = 1
}

variable "instance_class" {
  type        = string
  description = "The type of EC2 instance to run this on."
  default     = "db.t3.medium"
}

variable "name" {
  description = "(required) The name of the db also used for other identifiers"
  type        = string
}

variable "database_name" {
  type        = string
  description = "(required) The name of the database to be created inside the cluster."
}

###
# Common tags
###
variable "billing_tag_key" {
  description = "The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(required) The value of the billing tag"
  type        = string
}

###
# Database retention options
###

variable "preferred_backup_window" {
  description = "(required) The time you want your DB to be backedup. Takes the format `\"07:00-09:00\"`"
  type        = string
}

variable "backup_retention_period" {
  description = "(required) The amount of days to keep backups for."
  type        = number
}


###
# Network info
###

variable "vpc_id" {
  description = "(required) The vpc to run the cluster and related infrastructure in"
  type        = string
}

variable "subnet_ids" {
  description = "(required) The name of the subnet the DB has to stay in"
  type        = set(string)
}

variable "sg_ids" {
  description = "(required) The security groups this DB is to be attached to"
  type        = set(string)
}

###
# Database Admin User
###

variable "username" {
  description = "(required) The username for the admin user for the db"
  type        = string
}

variable "password" {
  type        = string
  description = "(required) The password for the admin user for the db"
  sensitive   = true
}

###
# Proxy Configuration
###

variable "proxy_log_retention_in_days" {
  type        = number
  description = "The number of days to retain the proxy logs in cloudwatch"
  default     = 14
}

variable "proxy_debug_logging" {
  type        = bool
  description = "Allows the proxy to log debug information. <br/> **Please Note:** This will include all sql commands and potential sensitive information"
  default     = false
}