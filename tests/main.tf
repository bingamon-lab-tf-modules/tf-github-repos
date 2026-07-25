module "test" {
  source = "../module"

  github_enterprise_slug   = "acme-corp"
  github_organization_name = "acme-engineering"

  github_repositories = [
    {
      name        = "acme-engineering/acme-service"
      description = "This is a test repository"
      visibility  = "public"

      has_issues      = true
      has_discussions = true
      has_projects    = true
      has_wiki        = true

      is_template = false

      rulesets = [
        {
          name        = "main-protection"
          enforcement = "active"
          target      = "branch"

          rules = {
            deletion         = true
            non_fast_forward = true

            branch_name_pattern = {
              operator = "starts_with"
              pattern  = "main"
            }

            pull_request = {
              required_approving_review_count = 1

              # Pull request required reviewers (provider 6.11.0)
              required_reviewers = [
                {
                  reviewer = {
                    id   = 1234567
                    type = "Team"
                  }
                  file_patterns     = ["infrastructure/**"]
                  minimum_approvals = 1
                }
              ]
            }

            # Copilot code review (provider 6.10.0)
            copilot_code_review = {
              review_on_push             = true
              review_draft_pull_requests = false
            }
          }

          bypass_actors = [
            {
              # OrganizationAdmin has no ID, so actor_id is deliberately omitted.
              actor_type  = "OrganizationAdmin"
              bypass_mode = "always"
            },
            {
              # User bypass actors require a numeric GitHub user ID.
              actor_id    = 7654321
              actor_type  = "User"
              bypass_mode = "pull_request"
            },
          ]

          conditions = {
            ref_name = {
              include = ["~DEFAULT_BRANCH"]
              exclude = []
            }
          }
        },
        {
          # Push rules (provider 6.8.0) only apply to the 'push' target.
          name        = "push-restrictions"
          enforcement = "active"
          target      = "push"

          rules = {
            max_file_size = {
              max_file_size = 100
            }

            max_file_path_length = {
              max_file_path_length = 255
            }

            file_extension_restriction = {
              restricted_file_extensions = ["*.exe", "*.dll"]
            }

            file_path_restriction = {
              restricted_file_paths = [".github/workflows/*"]
            }
          }

          bypass_actors = [
            {
              # DeployKey has no ID either, so actor_id is deliberately omitted.
              actor_type  = "DeployKey"
              bypass_mode = "always"
            },
          ]
        },
      ]
    }
  ]
}
