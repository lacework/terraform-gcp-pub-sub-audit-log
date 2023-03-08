provider "google" {}

provider "lacework" {}

module "gcp_project_level_pub_sub_audit_log" {
  source     = "../../"
  integration_type = "PROJECT"
  # project_id is set using GOOGLE_PROJECT env var
}
