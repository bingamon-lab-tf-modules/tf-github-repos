variable "github_enterprise_slug" {
  type        = string
  description = <<EOT
  The slug of the GitHub Enterprise where resources will be created.

  This is needed by the GitHub Enterprise Terraform provider.

  This can be set via either;

  - TF_VAR_github_enterprise_slug environment variable.
  - github_enterprise_slug variable in the terraform.tfvars file.
  EOT
}

variable "github_organization_name" {
  type        = string
  description = "Required. The name of the GitHub organization to create the team in."
}

variable "github_repositories" {
  description = "List of GitHub Repository configuration objects."
  type = list(object({
    # Repository
    name            = string
    description     = optional(string)
    homepage_url    = optional(string)
    visibility      = optional(string)
    has_issues      = optional(bool)
    has_discussions = optional(bool)
    has_projects    = optional(bool)
    has_wiki        = optional(bool)
    is_template     = optional(bool)

    allow_merge_commit          = optional(bool)
    allow_squash_merge          = optional(bool)
    allow_rebase_merge          = optional(bool)
    allow_auto_merge            = optional(bool)
    squash_merge_commit_title   = optional(string)
    squash_merge_commit_message = optional(string)
    merge_commit_title          = optional(string)
    merge_commit_message        = optional(string)
    delete_branch_on_merge      = optional(bool)

    web_commit_signoff_required = optional(bool)
    has_downloads               = optional(bool)
    auto_init                   = optional(bool)
    gitignore_template          = optional(string)
    license_template            = optional(string)

    archived           = optional(bool)
    archive_on_destroy = optional(bool)

    topics = optional(list(string))

    labels = optional(list(object({
      name        = string
      color       = string
      description = optional(string)
    })))

    rulesets = optional(list(object({
      # Required fields
      name        = string
      enforcement = string # disabled, active, evaluate
      target      = string # branch, tag

      # Rules block (required)
      rules = object({
        # Branch/Tag protection rules
        creation                      = optional(bool)
        deletion                      = optional(bool)
        non_fast_forward              = optional(bool)
        required_linear_history       = optional(bool)
        required_signatures           = optional(bool)
        update                        = optional(bool)
        update_allows_fetch_and_merge = optional(bool)

        # Pull request rules
        pull_request = optional(object({
          dismiss_stale_reviews_on_push     = optional(bool)
          require_code_owner_review         = optional(bool)
          require_last_push_approval        = optional(bool)
          required_approving_review_count   = optional(number)
          required_review_thread_resolution = optional(bool)
        }))

        # Status check rules
        required_status_checks = optional(object({
          strict_required_status_checks_policy = optional(bool)
          do_not_enforce_on_create             = optional(bool)
          required_check = list(object({
            context        = string
            integration_id = optional(number)
          }))
        }))

        # Deployment rules
        required_deployments = optional(object({
          required_deployment_environments = list(string)
        }))

        # Merge queue rules
        merge_queue = optional(object({
          check_response_timeout_minutes    = optional(number)
          grouping_strategy                 = optional(string) # ALLGREEN, HEADGREEN
          max_entries_to_build              = optional(number)
          max_entries_to_merge              = optional(number)
          merge_method                      = optional(string) # MERGE, SQUASH, REBASE
          min_entries_to_merge              = optional(number)
          min_entries_to_merge_wait_minutes = optional(number)
        }))

        # Code scanning rules
        required_code_scanning = optional(object({
          required_code_scanning_tool = list(object({
            alerts_threshold          = string # none, errors, errors_and_warnings, all
            security_alerts_threshold = string # none, critical, high_or_higher, medium_or_higher, all
            tool                      = string
          }))
        }))

        # Pattern rules (Enterprise only)
        branch_name_pattern = optional(object({
          operator = string # starts_with, ends_with, contains, regex
          pattern  = string
          name     = optional(string)
          negate   = optional(bool)
        }))

        tag_name_pattern = optional(object({
          operator = string # starts_with, ends_with, contains, regex
          pattern  = string
          name     = optional(string)
          negate   = optional(bool)
        }))

        commit_author_email_pattern = optional(object({
          operator = string # starts_with, ends_with, contains, regex
          pattern  = string
          name     = optional(string)
          negate   = optional(bool)
        }))

        commit_message_pattern = optional(object({
          operator = string # starts_with, ends_with, contains, regex
          pattern  = string
          name     = optional(string)
          negate   = optional(bool)
        }))

        committer_email_pattern = optional(object({
          operator = string # starts_with, ends_with, contains, regex
          pattern  = string
          name     = optional(string)
          negate   = optional(bool)
        }))
      })

      # Optional fields
      bypass_actors = optional(list(object({
        actor_id    = number
        actor_type  = string           # RepositoryRole, Team, Integration, OrganizationAdmin
        bypass_mode = optional(string) # always, pull_request
      })))

      conditions = optional(object({
        ref_name = object({
          include = list(string)
          exclude = list(string)
        })
      }))
    })))

    # NOTE:
    # This enables the following:
    #   - Dependency graph
    #   - Dependency alerts
    # This does NOT enable the following:
    #   - Dependabot security updates
    vulnerability_alerts = optional(bool, false)

    # GitHub Pages configuration
    pages = optional(object({
      source = object({
        branch = string
        path   = string
      })
      build_type = string
      cname      = string
    }))

    # Security and Analysis configuration
    security_and_analysis = optional(object({
      advanced_security = optional(object({
        status = string
      }))
      secret_scanning = optional(object({
        status = string
      }))
      secret_scanning_push_protection = optional(object({
        status = string
      }))
    }))

    # Team Permissions
    # Permission can be one of the following:
    # - pull
    # - triage
    # - push
    # - maintain
    # - admin
    teams = optional(list(object({
      name       = string
      permission = string
    })))

  }))

  default = []

  validation {
    condition = alltrue([
      for repo in var.github_repositories : repo.name != null && repo.name != ""
    ])
    error_message = <<EOT
    ❌ Repository validation has failed.

    All repositories must have a non-empty 'name' field.

    Please check your repository configuration and ensure every repository has a valid name.
    EOT
  }
}

variable "github_team_data" {
  description = "Map of team data from the teams module to avoid data source lookups"
  type = map(object({
    id   = string
    slug = string
    name = string
  }))
  default = {}
}
