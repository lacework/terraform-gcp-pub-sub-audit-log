terraform {
  required_providers {
    lacework = {
      source = "lacework/lacework"
    }
  }
}

provider "google" {}

provider "lacework" {}

variable "organization_id" {
  default = "my-organization-id"
}

variable "folders_to_exclude" {
  type = list(string)
}

module "gcp_organization_level_pub_sub_audit_log" {
  source             = "../../"
  integration_type   = "ORGANIZATION"
  organization_id    = var.organization_id
  folders_to_exclude = var.folders_to_exclude
}
