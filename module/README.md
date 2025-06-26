# tf-github-org-repos

## Table of Contents

- [tf-github-org-repos](#tf-github-org-repos)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Module Documentation](#module-documentation)
  - [Roadmap](#roadmap)

## Overview

This module configures repositories for a GitHub Organization.

## Module Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_issue_label.this](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/issue_label) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/repository) | resource |
| [github_repository_ruleset.this](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/repository_ruleset) | resource |
| [github_team_repository.this](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/team_repository) | resource |
| [github_organization.this](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/data-sources/organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_enterprise_slug"></a> [github\_enterprise\_slug](#input\_github\_enterprise\_slug) | The slug of the GitHub Enterprise where resources will be created.<br/><br/>  This is needed by the GitHub Enterprise Terraform provider.<br/><br/>  This can be set via either;<br/><br/>  - TF\_VAR\_github\_enterprise\_slug environment variable.<br/>  - github\_enterprise\_slug variable in the terraform.tfvars file. | `string` | n/a | yes |
| <a name="input_github_organization_name"></a> [github\_organization\_name](#input\_github\_organization\_name) | Required. The name of the GitHub organization to create the team in. | `string` | n/a | yes |
| <a name="input_github_repositories"></a> [github\_repositories](#input\_github\_repositories) | List of GitHub Repository configuration objects. | <pre>list(object({<br/>    # Repository<br/>    name            = string<br/>    description     = optional(string)<br/>    homepage_url    = optional(string)<br/>    visibility      = optional(string)<br/>    has_issues      = optional(bool)<br/>    has_discussions = optional(bool)<br/>    has_projects    = optional(bool)<br/>    has_wiki        = optional(bool)<br/>    is_template     = optional(bool)<br/><br/>    allow_merge_commit          = optional(bool)<br/>    allow_squash_merge          = optional(bool)<br/>    allow_rebase_merge          = optional(bool)<br/>    allow_auto_merge            = optional(bool)<br/>    squash_merge_commit_title   = optional(string)<br/>    squash_merge_commit_message = optional(string)<br/>    merge_commit_title          = optional(string)<br/>    merge_commit_message        = optional(string)<br/>    delete_branch_on_merge      = optional(bool)<br/><br/>    web_commit_signoff_required = optional(bool)<br/>    has_downloads               = optional(bool)<br/>    auto_init                   = optional(bool)<br/>    gitignore_template          = optional(string)<br/>    license_template            = optional(string)<br/><br/>    archived           = optional(bool)<br/>    archive_on_destroy = optional(bool)<br/><br/>    topics = optional(list(string))<br/><br/>    labels = optional(list(object({<br/>      name        = string<br/>      color       = string<br/>      description = optional(string)<br/>    })))<br/><br/>    rulesets = optional(list(object({<br/>      # Required fields<br/>      name        = string<br/>      enforcement = string # disabled, active, evaluate<br/>      target      = string # branch, tag<br/><br/>      # Rules block (required)<br/>      rules = object({<br/>        # Branch/Tag protection rules<br/>        creation                      = optional(bool)<br/>        deletion                      = optional(bool)<br/>        non_fast_forward              = optional(bool)<br/>        required_linear_history       = optional(bool)<br/>        required_signatures           = optional(bool)<br/>        update                        = optional(bool)<br/>        update_allows_fetch_and_merge = optional(bool)<br/><br/>        # Pull request rules<br/>        pull_request = optional(object({<br/>          dismiss_stale_reviews_on_push     = optional(bool)<br/>          require_code_owner_review         = optional(bool)<br/>          require_last_push_approval        = optional(bool)<br/>          required_approving_review_count   = optional(number)<br/>          required_review_thread_resolution = optional(bool)<br/>        }))<br/><br/>        # Status check rules<br/>        required_status_checks = optional(object({<br/>          strict_required_status_checks_policy = optional(bool)<br/>          do_not_enforce_on_create             = optional(bool)<br/>          required_check = list(object({<br/>            context        = string<br/>            integration_id = optional(number)<br/>          }))<br/>        }))<br/><br/>        # Deployment rules<br/>        required_deployments = optional(object({<br/>          required_deployment_environments = list(string)<br/>        }))<br/><br/>        # Merge queue rules<br/>        merge_queue = optional(object({<br/>          check_response_timeout_minutes    = optional(number)<br/>          grouping_strategy                 = optional(string) # ALLGREEN, HEADGREEN<br/>          max_entries_to_build              = optional(number)<br/>          max_entries_to_merge              = optional(number)<br/>          merge_method                      = optional(string) # MERGE, SQUASH, REBASE<br/>          min_entries_to_merge              = optional(number)<br/>          min_entries_to_merge_wait_minutes = optional(number)<br/>        }))<br/><br/>        # Code scanning rules<br/>        required_code_scanning = optional(object({<br/>          required_code_scanning_tool = list(object({<br/>            alerts_threshold          = string # none, errors, errors_and_warnings, all<br/>            security_alerts_threshold = string # none, critical, high_or_higher, medium_or_higher, all<br/>            tool                      = string<br/>          }))<br/>        }))<br/><br/>        # Pattern rules (Enterprise only)<br/>        branch_name_pattern = optional(object({<br/>          operator = string # starts_with, ends_with, contains, regex<br/>          pattern  = string<br/>          name     = optional(string)<br/>          negate   = optional(bool)<br/>        }))<br/><br/>        tag_name_pattern = optional(object({<br/>          operator = string # starts_with, ends_with, contains, regex<br/>          pattern  = string<br/>          name     = optional(string)<br/>          negate   = optional(bool)<br/>        }))<br/><br/>        commit_author_email_pattern = optional(object({<br/>          operator = string # starts_with, ends_with, contains, regex<br/>          pattern  = string<br/>          name     = optional(string)<br/>          negate   = optional(bool)<br/>        }))<br/><br/>        commit_message_pattern = optional(object({<br/>          operator = string # starts_with, ends_with, contains, regex<br/>          pattern  = string<br/>          name     = optional(string)<br/>          negate   = optional(bool)<br/>        }))<br/><br/>        committer_email_pattern = optional(object({<br/>          operator = string # starts_with, ends_with, contains, regex<br/>          pattern  = string<br/>          name     = optional(string)<br/>          negate   = optional(bool)<br/>        }))<br/>      })<br/><br/>      # Optional fields<br/>      bypass_actors = optional(list(object({<br/>        actor_id    = number<br/>        actor_type  = string           # RepositoryRole, Team, Integration, OrganizationAdmin<br/>        bypass_mode = optional(string) # always, pull_request<br/>      })))<br/><br/>      conditions = optional(object({<br/>        ref_name = object({<br/>          include = list(string)<br/>          exclude = list(string)<br/>        })<br/>      }))<br/>    })))<br/><br/>    # NOTE:<br/>    # This enables the following:<br/>    #   - Dependency graph<br/>    #   - Dependency alerts<br/>    # This does NOT enable the following:<br/>    #   - Dependabot security updates<br/>    vulnerability_alerts = optional(bool, false)<br/><br/>    # GitHub Pages configuration<br/>    pages = optional(object({<br/>      source = object({<br/>        branch = string<br/>        path   = string<br/>      })<br/>      build_type = string<br/>      cname      = string<br/>    }))<br/><br/>    # Security and Analysis configuration<br/>    security_and_analysis = optional(object({<br/>      advanced_security = optional(object({<br/>        status = string<br/>      }))<br/>      secret_scanning = optional(object({<br/>        status = string<br/>      }))<br/>      secret_scanning_push_protection = optional(object({<br/>        status = string<br/>      }))<br/>    }))<br/><br/>    # Team Permissions<br/>    # Permission can be one of the following:<br/>    # - pull<br/>    # - triage<br/>    # - push<br/>    # - maintain<br/>    # - admin<br/>    teams = optional(list(object({<br/>      name       = string<br/>      permission = string<br/>    })))<br/><br/>  }))</pre> | `[]` | no |
| <a name="input_github_team_data"></a> [github\_team\_data](#input\_github\_team\_data) | Map of team data from the teams module to avoid data source lookups | <pre>map(object({<br/>    id   = string<br/>    slug = string<br/>    name = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_labels"></a> [labels](#output\_labels) | Map of all repository labels created by this module |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | Map of all repositories created by this module |
| <a name="output_repository_names"></a> [repository\_names](#output\_repository\_names) | List of all repository names created by this module |
| <a name="output_rulesets"></a> [rulesets](#output\_rulesets) | Map of all repository rulesets created by this module |
<!-- END_TF_DOCS -->

## Roadmap

- [x] Complete MVP
- [ ] Add repository milestones
- [ ] Add repository releases
