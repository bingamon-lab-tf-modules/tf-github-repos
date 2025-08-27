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
      enforcement = string # disabled, active, evaluate (evaluate only supported for organization owners)
      target      = string # branch, tag

      # Rules block (required) - Rules within the ruleset
      rules = object({
        # Branch/Tag protection rules
        creation                      = optional(bool) # Only allow users with bypass permission to create matching refs
        deletion                      = optional(bool) # Only allow users with bypass permissions to delete matching refs
        non_fast_forward              = optional(bool) # Prevent users with push access from force pushing to branches
        required_linear_history       = optional(bool) # Prevent merge commits from being pushed to matching branches
        required_signatures           = optional(bool) # Commits pushed to matching branches must have verified signatures
        update                        = optional(bool) # Only allow users with bypass permission to update matching refs
        update_allows_fetch_and_merge = optional(bool) # Branch can pull changes from its upstream repository (forked repos only)

        # Pull request rules - Require all commits be made to a non-target branch and submitted via a pull request before they can be merged
        pull_request = optional(object({
          dismiss_stale_reviews_on_push     = optional(bool)   # New, reviewable commits pushed will dismiss previous pull request review approvals
          require_code_owner_review         = optional(bool)   # Require an approving review in pull requests that modify files that have a designated code owner
          require_last_push_approval        = optional(bool)   # Whether the most recent reviewable push must be approved by someone other than the person who pushed it
          required_approving_review_count   = optional(number) # The number of approving reviews that are required before a pull request can be merged
          required_review_thread_resolution = optional(bool)   # All conversations on code must be resolved before a pull request can be merged
        }))

        # Status check rules - Choose which status checks must pass before branches can be merged into a branch that matches this rule
        required_status_checks = optional(object({
          strict_required_status_checks_policy = optional(bool) # Whether pull requests targeting a matching branch must be tested with the latest code
          do_not_enforce_on_create             = optional(bool) # Allow repositories and branches to be created if a check would otherwise prohibit it
          required_check = list(object({
            context        = string           # The status check context name that must be present on the commit
            integration_id = optional(number) # The optional integration ID that this status check must originate from
          }))
        }))

        # Deployment rules - Choose which environments must be successfully deployed to before branches can be merged
        required_deployments = optional(object({
          required_deployment_environments = list(string) # The environments that must be successfully deployed to before branches can be merged
        }))

        # Merge queue rules - Merges must be performed via a merge queue
        merge_queue = optional(object({
          check_response_timeout_minutes    = optional(number) # Maximum time for a required status check to report a conclusion (default: 60)
          grouping_strategy                 = optional(string) # When set to ALLGREEN, the merge commit created by merge queue for each PR in the group must pass all required checks (ALLGREEN, HEADGREEN) (default: ALLGREEN)
          max_entries_to_build              = optional(number) # Limit the number of queued pull requests requesting checks and workflow runs at the same time (default: 5)
          max_entries_to_merge              = optional(number) # Limit the number of queued pull requests requesting checks and workflow runs at the same time (default: 5)
          merge_method                      = optional(string) # Method to use when merging changes from queued pull requests (MERGE, SQUASH, REBASE) (default: MERGE)
          min_entries_to_merge              = optional(number) # The minimum number of PRs that will be merged together in a group (default: 1)
          min_entries_to_merge_wait_minutes = optional(number) # The time merge queue should wait after the first PR is added to the queue for the minimum group size to be met (default: 5)
        }))

        # Code scanning rules - Define which tools must provide code scanning results before the reference is updated
        required_code_scanning = optional(object({
          required_code_scanning_tool = list(object({
            alerts_threshold          = string # none, errors, errors_and_warnings, all - The severity level at which code scanning results that raise alerts block a reference update
            security_alerts_threshold = string # none, critical, high_or_higher, medium_or_higher, all - The severity level at which code scanning results that raise security alerts block a reference update
            tool                      = string # The name of a code scanning tool
          }))
        }))

        # Pattern rules (Enterprise only) - These rules only apply to repositories within an enterprise, cannot be applied to individual or regular organization repositories
        branch_name_pattern = optional(object({
          operator = string           # starts_with, ends_with, contains, regex - The operator to use for matching
          pattern  = string           # The pattern to match with
          name     = optional(string) # How this rule will appear to users
          negate   = optional(bool)   # If true, the rule will fail if the pattern matches
        }))

        tag_name_pattern = optional(object({
          operator = string           # starts_with, ends_with, contains, regex - The operator to use for matching
          pattern  = string           # The pattern to match with
          name     = optional(string) # How this rule will appear to users
          negate   = optional(bool)   # If true, the rule will fail if the pattern matches
        }))

        commit_author_email_pattern = optional(object({
          operator = string           # starts_with, ends_with, contains, regex - The operator to use for matching
          pattern  = string           # The pattern to match with
          name     = optional(string) # How this rule will appear to users
          negate   = optional(bool)   # If true, the rule will fail if the pattern matches
        }))

        commit_message_pattern = optional(object({
          operator = string           # starts_with, ends_with, contains, regex - The operator to use for matching
          pattern  = string           # The pattern to match with
          name     = optional(string) # How this rule will appear to users
          negate   = optional(bool)   # If true, the rule will fail if the pattern matches
        }))

        committer_email_pattern = optional(object({
          operator = string           # starts_with, ends_with, contains, regex - The operator to use for matching
          pattern  = string           # The pattern to match with
          name     = optional(string) # How this rule will appear to users
          negate   = optional(bool)   # If true, the rule will fail if the pattern matches
        }))
      })

      # Optional fields
      bypass_actors = optional(list(object({
        actor_id    = number           # The ID of the actor that can bypass a ruleset. If actor_type is Integration, actor_id is a GitHub App ID
        actor_type  = string           # RepositoryRole, Team, Integration, OrganizationAdmin - The type of actor that can bypass a ruleset
        bypass_mode = optional(string) # always, pull_request - When the specified actor can bypass the ruleset
      })))

      conditions = optional(object({
        ref_name = object({
          include = list(string) # Array of ref names or patterns to include. One of these patterns must match for the condition to pass
          exclude = list(string) # Array of ref names or patterns to exclude. The condition will not pass if any of these patterns match
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

      # GitHub Pages build type
      build_type = string # workflow, legacy

      # Optional CNAME for the GitHub Pages site
      cname = optional(string)

      # Legacy GitHub Pages configuration
      source = optional(object({
        branch = string
        path   = string
      }))

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
