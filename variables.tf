variable "required_apis" {
  type = map(any)
  default = {
    iam             = "iam.googleapis.com"
    pubsub          = "pubsub.googleapis.com"
    serviceusage    = "serviceusage.googleapis.com"
    resourcemanager = "cloudresourcemanager.googleapis.com"
  }
}

variable "integration_type" {
  type        = string
  default     = "PROJECT"
  description = "Specify the integration type. Can only be PROJECT or ORGANIZATION. Defaults to PROJECT"
  validation {
    condition =  contains(["PROJECT", "ORGANIZATION"], var.integration_type)
    error_message = "The integration_type must be either PROJECT or ORGANIZATION."
  }
}

variable "organization_id" {
  type        = string
  default     = ""
  description = "The organization ID, required if integration_type is set to ORGANIZATION"
}

variable "project_id" {
  type        = string
  default     = ""
  description = "A project ID different from the default defined inside the provider"
  validation {
    condition     = can(regex("(^[a-z][a-z0-9-]{4,28}[a-z0-9]$|^$)", var.project_id))
    error_message = "The project_id variable must be a valid GCP project ID. It must be 6 to 30 lowercase ASCII letters, digits, or hyphens. It must start with a letter. Trailing hyphens are prohibited.. Example: tokyo-rain-123."
  }
}

variable "use_existing_service_account" {
  type        = bool
  default     = false
  description = "Set this to true to use an existing Service Account"
}

variable "service_account_name" {
  type        = string
  default     = ""
  description = "The Service Account name (required when use_existing_service_account is set to true)"
}

variable "service_account_private_key" {
  type        = string
  default     = ""
  description = "The private key in JSON format, base64 encoded (required when use_existing_service_account is set to true)"
}

variable "existing_sink_name" {
  type        = string
  default     = ""
  description = "The name of an existing sink to be re-used for this integration"
}

variable "prefix" {
  type        = string
  default     = "lw-al-ps"
  description = "The prefix that will be use at the beginning of every generated resource"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Set of labels which will be added to the resources managed by the module"
}

variable "lacework_integration_name" {
  type    = string
  default = "TF pub_sub_audit_log"
}

variable "wait_time" {
  type        = string
  default     = "10s"
  description = "Amount of time to wait before the next resource is provisioned."
}

variable "pubsub_topic_labels" {
  type        = map(string)
  default     = {}
  description = "Set of labels which will be added to the topic"
}

variable "pubsub_subscription_labels" {
  type        = map(string)
  default     = {}
  description = "Set of labels which will be added to the subscription"
}

variable "k8s_filter" {
  type        = bool
  default     = true
  description = "Filter out GKE logs from GCP Audit Log sinks.  Default is true"
}

variable "google_workspace_filter" {
  type        = bool
  default     = true
  description = "Filter out Google Workspace login logs from GCP Audit Log sinks.  Default is true"
}

variable "custom_filter" {
  type        = string
  default     = ""
  description = "Customer defined Audit Log filter which will supersede all other filter options when defined" 
}
