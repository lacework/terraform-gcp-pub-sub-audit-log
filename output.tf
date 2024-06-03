output "service_account_name" {
  value       = local.service_account_name
  description = "The Service Account name"
}

output "service_account_private_key" {
  value       = length(var.service_account_private_key) > 0 ? null : module.lacework_al_ps_svc_account.private_key
  description = "The private key in JSON format, base64 encoded"
  sensitive   = true
}

output "pubsub_subscription_name" {
  value       = google_pubsub_subscription.lacework_subscription.name
  description = "The PubSub subscription name"
}

output "pubsub_topic_name" {
  value       = google_pubsub_topic.lacework_topic.name
  description = "The PubSub topic name"
}

output "sink_name" {
  value       = local.sink_name
  description = "The sink name"
}

output "lacework_integration_guid" {
  value       = length(lacework_integration_gcp_pub_sub_audit_log.default) > 0 ? lacework_integration_gcp_pub_sub_audit_log.default[0].intg_guid : null
  description = "GUID of the created Lacework integration"
}

