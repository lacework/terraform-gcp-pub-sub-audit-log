# Integrate GCP Organization Pub Sub Audit logs with Lacework — Including only some organization folders
The following provides an example of integrating a Google Cloud Project Audit Logs with 
Lacework for analysis, but includes only a subset of organization folders in the integration.

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
  folders_to_include = ["folders/000000000123"]
}
```