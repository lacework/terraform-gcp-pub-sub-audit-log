# Integrate GCP Project Pub Sub Audit logs with Lacework
The following provides an example of integrating a Google Cloud Project Audit Logs with 
Lacework for analysis.

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

module "gcp_project_level_pub_sub_audit_log" {
  source           = "lacework/pub-sub-audit-log/gcp"
  version          = "~> 0.1"
  integration_type = "PROJECT"
  project_id       = "example-project-123"
}
```