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
  value       = local.subscription_name
  description = "The PubSub subscription name"
}

output "pubsub_topic_name" {
  value       = local.topic_name
  description = "The PubSub topic name"
}

output "sink_name" {
  value       = local.sink_name
  description = "The sink name"
}

