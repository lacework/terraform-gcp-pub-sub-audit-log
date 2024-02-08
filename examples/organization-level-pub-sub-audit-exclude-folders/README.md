# Integrate GCP Organization Pub Sub Audit logs with Lacework — Including only some organization folders
The following provides an example of integrating a Google Cloud Project Audit Logs with 
Lacework for analysis, but excludes some organization folders in the integration.


```hcl
terraform {
  required_providers {
    lacework = {
      source = "lacework/lacework"
    }
  }
}

provider "google" {}

provider "lacework" {}

module "gcp_organization_level_pub_sub_audit_log" {
  source           = "lacework/pub-sub-audit-log/gcp"
  version          = "~> 0.1"
  integration_type = "ORGANIZATION"
  project_id       = "example-project-123"
  organization_id  = "example-org-123"
  folders_to_exclude = [
    "folders/0000000000001",
    "folders/0000000000002",
    "folders/0000000000003",
    "folders/0000000000004"
  ]
}
```