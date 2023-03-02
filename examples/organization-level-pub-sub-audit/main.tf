provider "google" {}

provider "lacework" {}

variable "organization_id" {
  default = "my-organization-id"
}

module "gcp_organization_level_pub_sub_audit_log" {
  source     = "../../"
  integration_type = "ORGANIZATION"
  organization_id = var.organization_id
}
