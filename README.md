<a href="https://lacework.com"><img src="https://techally-content.s3-us-west-1.amazonaws.com/public-content/lacework_logo_full.png" width="600"></a>

# terraform-gcp-pub-sub-audit-log

[![GitHub release](https://img.shields.io/github/release/lacework/terraform-gcp-pub-sub-audit-log.svg)](https://github.com/lacework/terraform-gcp-pub-sub-audit-log/releases/)
[![Codefresh build status]( https://g.codefresh.io/api/badges/pipeline/lacework/terraform-modules%2Ftest-compatibility?type=cf-1&key=eyJhbGciOiJIUzI1NiJ9.NWVmNTAxOGU4Y2FjOGQzYTkxYjg3ZDEx.RJ3DEzWmBXrJX7m38iExJ_ntGv4_Ip8VTa-an8gBwBo)]( https://g.codefresh.io/pipelines/edit/new/builds?id=607e25e6728f5a6fba30431b&pipeline=test-compatibility&projects=terraform-modules&projectId=607db54b728f5a5f8930405d)

A Terraform Module to configuring an integration with Google Cloud Platform Pub Sub Audit Logs with 
Lacework for analysis.

:warning: - **NOTE:** When using an existing Service Account, Terraform cannot work out whether a 
role has already been applied. This means when running the destroy step, existing roles may be 
removed from the Service Account. If this Service Account is managed by another Terraform module, 
you can re-run apply on the other module and this will re-add the role.

Alternatively, it is possible to remove the offending roles from the state file before destroy, 
preventing the role(s) from being removed.

e.g. `terraform state rm 'google_project_iam_binding.for_lacework_service_account'`

## Required Roles

```
roles/pubsub.publisher
roles/pubsub.subscriber
```

## Required APIs

```
iam.googleapis.com
pubsub.googleapis.com
serviceusage.googleapis.com
cloudresourcemanager.googleapis.com
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.4.0 |
| <a name="requirement_lacework"></a> [lacework](#requirement\_lacework) | ~> 1.18 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.4.0 |
| <a name="provider_lacework"></a> [lacework](#provider\_lacework) | ~> 1.18 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lacework_al_ps_svc_account"></a> [lacework\_al\_ps\_svc\_account](#module\_lacework\_al\_ps\_svc\_account) | lacework/service-account/gcp | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [google_logging_folder_sink.lacework_folder_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_folder_sink) | resource |
| [google_logging_organization_sink.lacework_organization_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_logging_project_sink.lacework_project_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_logging_project_sink.lacework_root_project_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_organization_iam_audit_config.organization_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_audit_config) | resource |
| [google_organization_iam_member.for_lacework_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_audit_config.project_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_audit_config) | resource |
| [google_project_iam_member.for_lacework_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.required_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_pubsub_subscription.lacework_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription_iam_binding.lacework](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_binding) | resource |
| [google_pubsub_topic.lacework_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_binding.topic_publisher](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_binding) | resource |
| [lacework_integration_gcp_pub_sub_audit_log.default](https://registry.terraform.io/providers/lacework/lacework/latest/docs/resources/integration_gcp_pub_sub_audit_log) | resource |
| [random_id.uniq](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [time_sleep.wait_time](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_folders.my-org-folders](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folders) | data source |
| [google_project.selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_projects.my-org-projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |
| [lacework_metric_module.lwmetrics](https://registry.terraform.io/providers/lacework/lacework/latest/docs/data-sources/metric_module) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_filter"></a> [custom\_filter](#input\_custom\_filter) | Customer defined Audit Log filter which will supersede all other filter options when defined | `string` | `""` | no |
| <a name="input_existing_sink_name"></a> [existing\_sink\_name](#input\_existing\_sink\_name) | The name of an existing sink to be re-used for this integration | `string` | `""` | no |
| <a name="input_folders_to_exclude"></a> [folders\_to\_exclude](#input\_folders\_to\_exclude) | List of root folders to exclude in an organization-level integration.  Format is 'folders/1234567890' | `list(string)` | `[]` | no |
| <a name="input_folders_to_include"></a> [folders\_to\_include](#input\_folders\_to\_include) | List of root folders to include in an organization-level integration.  Format is 'folders/1234567890' | `set(string)` | `[]` | no |
| <a name="input_google_workspace_filter"></a> [google\_workspace\_filter](#input\_google\_workspace\_filter) | Filter out Google Workspace login logs from GCP Audit Log sinks.  Default is true | `bool` | `true` | no |
| <a name="input_include_root_projects"></a> [include\_root\_projects](#input\_include\_root\_projects) | Enables logic to include root-level projects if excluding folders.  Default is true | `bool` | `true` | no |
| <a name="input_integration_type"></a> [integration\_type](#input\_integration\_type) | Specify the integration type. Can only be PROJECT or ORGANIZATION. Defaults to PROJECT | `string` | `"PROJECT"` | no |
| <a name="input_k8s_filter"></a> [k8s\_filter](#input\_k8s\_filter) | Filter out GKE logs from GCP Audit Log sinks.  Default is true | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Set of labels which will be added to the resources managed by the module | `map(string)` | `{}` | no |
| <a name="input_lacework_integration_name"></a> [lacework\_integration\_name](#input\_lacework\_integration\_name) | n/a | `string` | `"TF pub_sub_audit_log"` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | The organization ID, required if integration\_type is set to ORGANIZATION | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix that will be use at the beginning of every generated resource | `string` | `"lw-al-ps"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | A project ID different from the default defined inside the provider | `string` | `""` | no |
| <a name="input_pubsub_subscription_labels"></a> [pubsub\_subscription\_labels](#input\_pubsub\_subscription\_labels) | Set of labels which will be added to the subscription | `map(string)` | `{}` | no |
| <a name="input_pubsub_topic_labels"></a> [pubsub\_topic\_labels](#input\_pubsub\_topic\_labels) | Set of labels which will be added to the topic | `map(string)` | `{}` | no |
| <a name="input_required_apis"></a> [required\_apis](#input\_required\_apis) | n/a | `map(any)` | <pre>{<br>  "iam": "iam.googleapis.com",<br>  "pubsub": "pubsub.googleapis.com",<br>  "resourcemanager": "cloudresourcemanager.googleapis.com",<br>  "serviceusage": "serviceusage.googleapis.com"<br>}</pre> | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | The Service Account name (required when use\_existing\_service\_account is set to true) | `string` | `""` | no |
| <a name="input_service_account_private_key"></a> [service\_account\_private\_key](#input\_service\_account\_private\_key) | The private key in JSON format, base64 encoded (required when use\_existing\_service\_account is set to true) | `string` | `""` | no |
| <a name="input_skip_create_lacework_integration"></a> [skip\_create\_lacework\_integration](#input\_skip\_create\_lacework\_integration) | Set this to true to skip creating the LW integration during GCPv1 to GCPv2 migration | `bool` | `false` | no |
| <a name="input_use_existing_service_account"></a> [use\_existing\_service\_account](#input\_use\_existing\_service\_account) | Set this to true to use an existing Service Account | `bool` | `false` | no |
| <a name="input_wait_time"></a> [wait\_time](#input\_wait\_time) | Amount of time to wait before the next resource is provisioned. | `string` | `"10s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pubsub_subscription_name"></a> [pubsub\_subscription\_name](#output\_pubsub\_subscription\_name) | The PubSub subscription name |
| <a name="output_pubsub_topic_name"></a> [pubsub\_topic\_name](#output\_pubsub\_topic\_name) | The PubSub topic name |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | The Service Account name |
| <a name="output_service_account_private_key"></a> [service\_account\_private\_key](#output\_service\_account\_private\_key) | The private key in JSON format, base64 encoded |
| <a name="output_sink_name"></a> [sink\_name](#output\_sink\_name) | The sink name |
<!-- END_TF_DOCS -->