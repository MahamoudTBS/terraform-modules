#!/bin/bash

echo 🚧 Terraform Module Scaffold 🚧

# shellcheck disable=SC2162
read -p "Scaffold Name: " module

mkdir -p "$module"

echo 🚧 Creating module

echo 📝 Creating "$module/Makefile"
cat << EOF > "$module/Makefile"
.PHONY: fmt docs

fmt:
	@terraform fmt -recursive

docs:
	@terraform-docs markdown -c ../.terraform-docs.yml . > README.md
EOF

echo 📝 Creating "$module/input.tf"
cat << EOF > "$module/input.tf"

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

EOF

echo 📝 Creating "$module/locals.tf"
cat << EOF > "$module/locals.tf"

locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}

EOF

echo 📝 Creating "$module/main.tf"
cat << EOF > "$module/main.tf"
/* # $module
*
*/
EOF

echo 👉 Touching "$module/output.tf"
touch "$module/output.tf"

echo "📝 Appending to .modules file, (this adds it to the Makefile)"
echo -n " $module" >> .modules

[ -f "$module/Makefile" ]
[ -f "$module/input.tf" ]
[ -f "$module/locals.tf" ]
[ -f "$module/main.tf" ]
[ -f "$module/output.tf" ]
echo ✅ Done