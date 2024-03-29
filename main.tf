locals {
  org_integration = var.integration_type == "ORGANIZATION"
  project_id      = length(var.project_id) > 0 ? var.project_id : data.google_project.selected[0].project_id
  sink_name = length(var.existing_sink_name) > 0 ? var.existing_sink_name : (
    local.org_integration ? "${var.prefix}-${var.organization_id}-lacework-sink-${random_id.uniq.hex}" : "${var.prefix}-lacework-sink-${random_id.uniq.hex}"
  )

  exclude_folders  = length(var.folders_to_exclude) != 0
  explicit_folders = length(var.folders_to_include) != 0

  logging_sink_writer_identity = length(var.existing_sink_name) > 0 ? ["serviceAccount:${local.service_account_json_key.client_email}"] : (
    (local.org_integration && !(local.exclude_folders || local.explicit_folders)) ? (
      [google_logging_organization_sink.lacework_organization_sink[0].writer_identity]
      ) : (
      (local.org_integration && (local.exclude_folders || local.explicit_folders)) ? (
        concat(
          [for v in google_logging_folder_sink.lacework_folder_sink : v.writer_identity],
          [for v in google_logging_project_sink.lacework_root_project_sink : v.writer_identity]
        )
        ) : (
        [google_logging_project_sink.lacework_project_sink[0].writer_identity]
      )
    )
  )

  service_account_name = var.use_existing_service_account ? (
    var.service_account_name
    ) : (
    length(var.service_account_name) > 0 ? var.service_account_name : "${var.prefix}-${random_id.uniq.hex}"
  )
  service_account_json_key = jsondecode(var.use_existing_service_account ? (
    base64decode(var.service_account_private_key)
    ) : (
    base64decode(module.lacework_al_ps_svc_account.private_key)
  ))

  log_filter_map = {
    default                = "(protoPayload.@type=type.googleapis.com/google.cloud.audit.AuditLog) AND NOT (protoPayload.methodName:\"storage.objects\")"
    k8s_only               = "(protoPayload.@type=type.googleapis.com/google.cloud.audit.AuditLog) AND NOT (protoPayload.serviceName=\"k8s.io\") AND NOT (protoPayload.methodName:\"storage.objects\")"
    workspace_only         = "(protoPayload.@type=type.googleapis.com/google.cloud.audit.AuditLog) AND NOT (protoPayload.methodName:\"storage.objects\") AND NOT (protoPayload.serviceName:\"login.googleapis.com\")"
    k8s_workspace_combined = "(protoPayload.@type=type.googleapis.com/google.cloud.audit.AuditLog) AND NOT (protoPayload.serviceName=\"k8s.io\") AND NOT (protoPayload.serviceName:\"login.googleapis.com\") AND NOT (protoPayload.methodName:\"storage.objects\")"
  }

  log_filter = length(var.custom_filter) > 0 ? (var.custom_filter) : (
    !var.k8s_filter && !var.google_workspace_filter ? ("${lookup(local.log_filter_map, "default")}") : (
      var.k8s_filter && !var.google_workspace_filter ?
      "${lookup(local.log_filter_map, "k8s_only")}" : (
        !var.k8s_filter && var.google_workspace_filter ?
        "${lookup(local.log_filter_map, "workspace_only")}" : (
          "${lookup(local.log_filter_map, "k8s_workspace_combined")}"
        )
      )
    )
  )

  folders = [
    # if setting up an org-level integration and excluding folders
    (local.org_integration && local.exclude_folders) ? (
      # for the folders in the given org, get just the folders that haven't been excluded
      setsubtract(data.google_folders.my-org-folders[0].folders[*].name, var.folders_to_exclude)
      ) : ( # org integration but NOT excluding folders, including them; use the supplied foldes to include
      local.org_integration && local.explicit_folders) ? (
      var.folders_to_include
      ) : (
      # if we got this far, this is an org integration but no folder inclusions or exclusions have been set
      # we'll return an empty set but the logic for lacework_organization_sink will deploy an org-wide sink
      # that'll catch all folders (not true if inclusions/exclusions are set)
      toset([])
    )
  ]

  root_projects = [
    (local.org_integration && local.exclude_folders && var.include_root_projects) ? (
      toset(data.google_projects.my-org-projects[0].projects[*].project_id)
      ) : (
      toset([])
    )
  ]

  version_file   = "${abspath(path.module)}/VERSION"
  module_name    = "terraform-gcp-pub-sub-audit-log"
  module_version = fileexists(local.version_file) ? file(local.version_file) : ""
}

resource "random_id" "uniq" {
  byte_length = 4
}

data "google_project" "selected" {
  count = length(var.project_id) > 0 ? 0 : 1
}

data "google_folders" "my-org-folders" {
  count     = (local.org_integration && local.exclude_folders) ? 1 : 0
  parent_id = "organizations/${var.organization_id}"
}

data "google_projects" "my-org-projects" {
  count  = (local.exclude_folders && var.include_root_projects) ? 1 : 0
  filter = "parent.id=${var.organization_id}"
}

resource "google_project_service" "required_apis" {
  for_each = var.required_apis
  project  = local.project_id
  service  = each.value

  disable_on_destroy = false
}

module "lacework_al_ps_svc_account" {
  source               = "lacework/service-account/gcp"
  version              = "~> 2.0"
  create               = var.use_existing_service_account ? false : true
  service_account_name = local.service_account_name
  project_id           = local.project_id
}

resource "google_pubsub_topic" "lacework_topic" {
  name       = "${var.prefix}-lacework-topic-${random_id.uniq.hex}"
  project    = local.project_id
  depends_on = [google_project_service.required_apis]
  labels     = merge(var.labels, var.pubsub_topic_labels)
}

resource "google_pubsub_topic_iam_binding" "topic_publisher" {
  members    = local.logging_sink_writer_identity
  role       = "roles/pubsub.publisher"
  project    = local.project_id
  topic      = google_pubsub_topic.lacework_topic.name
  depends_on = [google_pubsub_topic.lacework_topic]
}

resource "google_pubsub_subscription" "lacework_subscription" {
  project                    = local.project_id
  name                       = "${var.prefix}-${local.project_id}-lacework-subscription-${random_id.uniq.hex}"
  topic                      = google_pubsub_topic.lacework_topic.name
  ack_deadline_seconds       = 300
  message_retention_duration = "432000s"
  labels                     = merge(var.labels, var.pubsub_subscription_labels)
  depends_on                 = [google_pubsub_topic.lacework_topic]
}

resource "google_logging_project_sink" "lacework_project_sink" {
  count                  = length(var.existing_sink_name) > 0 ? 0 : (local.org_integration ? 0 : 1)
  project                = local.project_id
  name                   = local.sink_name
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.lacework_topic.id}"
  unique_writer_identity = true

  filter = local.log_filter

  depends_on = [google_pubsub_topic.lacework_topic]
}

resource "google_logging_project_sink" "lacework_root_project_sink" {
  for_each               = local.root_projects[0]
  project                = each.value
  name                   = local.sink_name
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.lacework_topic.id}"
  unique_writer_identity = true

  filter     = local.log_filter
  depends_on = [google_pubsub_topic.lacework_topic]
}

resource "google_logging_folder_sink" "lacework_folder_sink" {
  for_each         = local.folders[0]
  name             = local.sink_name
  folder           = each.value
  destination      = "pubsub.googleapis.com/${google_pubsub_topic.lacework_topic.id}"
  include_children = true

  filter = local.log_filter
}

resource "google_logging_organization_sink" "lacework_organization_sink" {
  count            = length(var.existing_sink_name) > 0 ? 0 : ((local.org_integration && !(local.exclude_folders || local.explicit_folders) ? 1 : 0))
  name             = local.sink_name
  org_id           = var.organization_id
  destination      = "pubsub.googleapis.com/${google_pubsub_topic.lacework_topic.id}"
  include_children = true

  filter = local.log_filter

  depends_on = [google_pubsub_topic.lacework_topic]
}

resource "google_pubsub_subscription_iam_binding" "lacework" {
  project      = local.project_id
  role         = "roles/pubsub.subscriber"
  members      = ["serviceAccount:${local.service_account_json_key.client_email}"]
  subscription = google_pubsub_subscription.lacework_subscription.name
  depends_on   = [google_pubsub_subscription.lacework_subscription]
}

resource "google_project_iam_audit_config" "project_audit_logs" {
  project = local.project_id
  service = "container.googleapis.com"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_organization_iam_audit_config" "organization_audit_logs" {
  count   = local.org_integration ? 1 : 0
  org_id  = var.organization_id
  service = "container.googleapis.com"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_project_iam_member" "for_lacework_service_account" {
  project = local.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${local.service_account_json_key.client_email}"
}

resource "google_organization_iam_member" "for_lacework_service_account" {
  count  = local.org_integration ? 1 : 0
  org_id = var.organization_id
  role   = "roles/browser"
  member = "serviceAccount:${local.service_account_json_key.client_email}"
}

# wait for X seconds for things to settle down in the GCP side
# before trying to create the Lacework external integration
resource "time_sleep" "wait_time" {
  create_duration = var.wait_time
  depends_on = [
    google_pubsub_subscription_iam_binding.lacework,
    module.lacework_al_ps_svc_account,
    google_project_iam_audit_config.project_audit_logs,
    google_organization_iam_audit_config.organization_audit_logs,
    google_project_iam_member.for_lacework_service_account,
    google_organization_iam_member.for_lacework_service_account
  ]
}

resource "lacework_integration_gcp_pub_sub_audit_log" "default" {
  count            = var.skip_create_lacework_integration ? 0 : 1
  name             = var.lacework_integration_name
  integration_type = var.integration_type
  project_id       = local.project_id
  organization_id  = var.organization_id
  subscription_id  = google_pubsub_subscription.lacework_subscription.id
  topic_id         = google_pubsub_topic.lacework_topic.id
  credentials {
    client_id      = local.service_account_json_key.client_id
    private_key_id = local.service_account_json_key.private_key_id
    client_email   = local.service_account_json_key.client_email
    private_key    = local.service_account_json_key.private_key
  }
  depends_on = [time_sleep.wait_time]
}

data "lacework_metric_module" "lwmetrics" {
  name    = local.module_name
  version = local.module_version
}
