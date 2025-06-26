# Repository Rulesets
resource "github_repository_ruleset" "this" {
  for_each = {
    for item in flatten([
      for repo in var.github_repositories : [
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) : {
          key       = "${repo.name}:${ruleset.name}"
          repo_name = repo.name
          ruleset   = ruleset
        }
      ]
    ]) : item.key => item
  }

  repository  = each.value.repo_name
  name        = each.value.ruleset.name
  enforcement = each.value.ruleset.enforcement
  target      = each.value.ruleset.target

  # Rules block
  rules {
    # Basic protection rules
    creation                      = try(each.value.ruleset.rules.creation, null)
    deletion                      = try(each.value.ruleset.rules.deletion, null)
    non_fast_forward              = try(each.value.ruleset.rules.non_fast_forward, null)
    required_linear_history       = try(each.value.ruleset.rules.required_linear_history, null)
    required_signatures           = try(each.value.ruleset.rules.required_signatures, null)
    update                        = try(each.value.ruleset.rules.update, null)
    update_allows_fetch_and_merge = try(each.value.ruleset.rules.update_allows_fetch_and_merge, null)

    # Pull request rules
    dynamic "pull_request" {
      for_each = each.value.ruleset.rules.pull_request != null ? [each.value.ruleset.rules.pull_request] : []
      content {
        dismiss_stale_reviews_on_push     = try(pull_request.value.dismiss_stale_reviews_on_push, null)
        require_code_owner_review         = try(pull_request.value.require_code_owner_review, null)
        require_last_push_approval        = try(pull_request.value.require_last_push_approval, null)
        required_approving_review_count   = try(pull_request.value.required_approving_review_count, null)
        required_review_thread_resolution = try(pull_request.value.required_review_thread_resolution, null)
      }
    }

    # Status check rules
    dynamic "required_status_checks" {
      for_each = each.value.ruleset.rules.required_status_checks != null ? [each.value.ruleset.rules.required_status_checks] : []
      content {
        strict_required_status_checks_policy = try(required_status_checks.value.strict_required_status_checks_policy, null)
        do_not_enforce_on_create             = try(required_status_checks.value.do_not_enforce_on_create, null)

        dynamic "required_check" {
          for_each = required_status_checks.value.required_check != null ? required_status_checks.value.required_check : []
          content {
            context        = required_check.value.context
            integration_id = try(required_check.value.integration_id, null)
          }
        }
      }
    }

    # Deployment rules
    dynamic "required_deployments" {
      for_each = each.value.ruleset.rules.required_deployments != null ? [each.value.ruleset.rules.required_deployments] : []
      content {
        required_deployment_environments = required_deployments.value.required_deployment_environments
      }
    }

    # Merge queue rules
    dynamic "merge_queue" {
      for_each = each.value.ruleset.rules.merge_queue != null ? [each.value.ruleset.rules.merge_queue] : []
      content {
        check_response_timeout_minutes    = try(merge_queue.value.check_response_timeout_minutes, 60)
        grouping_strategy                 = try(merge_queue.value.grouping_strategy, "ALLGREEN")
        max_entries_to_build              = try(merge_queue.value.max_entries_to_build, 5)
        max_entries_to_merge              = try(merge_queue.value.max_entries_to_merge, 5)
        merge_method                      = try(merge_queue.value.merge_method, "MERGE")
        min_entries_to_merge              = try(merge_queue.value.min_entries_to_merge, 1)
        min_entries_to_merge_wait_minutes = try(merge_queue.value.min_entries_to_merge_wait_minutes, 5)
      }
    }

    # Code scanning rules
    dynamic "required_code_scanning" {
      for_each = each.value.ruleset.rules.required_code_scanning != null ? [each.value.ruleset.rules.required_code_scanning] : []
      content {
        dynamic "required_code_scanning_tool" {
          for_each = required_code_scanning.value.required_code_scanning_tool != null ? required_code_scanning.value.required_code_scanning_tool : []
          content {
            alerts_threshold          = required_code_scanning_tool.value.alerts_threshold
            security_alerts_threshold = required_code_scanning_tool.value.security_alerts_threshold
            tool                      = required_code_scanning_tool.value.tool
          }
        }
      }
    }

    # Pattern rules (Enterprise only)
    dynamic "branch_name_pattern" {
      for_each = each.value.ruleset.rules.branch_name_pattern != null ? [each.value.ruleset.rules.branch_name_pattern] : []
      content {
        operator = branch_name_pattern.value.operator
        pattern  = branch_name_pattern.value.pattern
        name     = try(branch_name_pattern.value.name, null)
        negate   = try(branch_name_pattern.value.negate, null)
      }
    }

    dynamic "tag_name_pattern" {
      for_each = each.value.ruleset.rules.tag_name_pattern != null ? [each.value.ruleset.rules.tag_name_pattern] : []
      content {
        operator = tag_name_pattern.value.operator
        pattern  = tag_name_pattern.value.pattern
        name     = try(tag_name_pattern.value.name, null)
        negate   = try(tag_name_pattern.value.negate, null)
      }
    }

    dynamic "commit_author_email_pattern" {
      for_each = each.value.ruleset.rules.commit_author_email_pattern != null ? [each.value.ruleset.rules.commit_author_email_pattern] : []
      content {
        operator = commit_author_email_pattern.value.operator
        pattern  = commit_author_email_pattern.value.pattern
        name     = try(commit_author_email_pattern.value.name, null)
        negate   = try(commit_author_email_pattern.value.negate, null)
      }
    }

    dynamic "commit_message_pattern" {
      for_each = each.value.ruleset.rules.commit_message_pattern != null ? [each.value.ruleset.rules.commit_message_pattern] : []
      content {
        operator = commit_message_pattern.value.operator
        pattern  = commit_message_pattern.value.pattern
        name     = try(commit_message_pattern.value.name, null)
        negate   = try(commit_message_pattern.value.negate, null)
      }
    }

    dynamic "committer_email_pattern" {
      for_each = each.value.ruleset.rules.committer_email_pattern != null ? [each.value.ruleset.rules.committer_email_pattern] : []
      content {
        operator = committer_email_pattern.value.operator
        pattern  = committer_email_pattern.value.pattern
        name     = try(committer_email_pattern.value.name, null)
        negate   = try(committer_email_pattern.value.negate, null)
      }
    }
  }

  # Bypass actors
  dynamic "bypass_actors" {
    for_each = each.value.ruleset.bypass_actors != null ? each.value.ruleset.bypass_actors : []
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = try(bypass_actors.value.bypass_mode, null)
    }
  }

  # Conditions
  dynamic "conditions" {
    for_each = each.value.ruleset.conditions != null ? [each.value.ruleset.conditions] : []
    content {
      ref_name {
        include = conditions.value.ref_name.include
        exclude = conditions.value.ref_name.exclude
      }
    }
  }

  # Workaround for GitHub provider issue with OrganizationAdmin actor_id
  # The provider reads back actor_id = 0 instead of 1 for OrganizationAdmin
  # causing perpetual drift. Ignore changes to bypass_actors to prevent this.
  # Refer issue #2536
  lifecycle {
    ignore_changes = [
      #bypass_actors
    ]
  }

  depends_on = [
    github_repository.this
  ]
}
