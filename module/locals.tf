locals {
  # Compute repositories with conditional merge commit settings
  # This is to workaround lack of dynamic blocks in the provider.
  repositories_with_conditional_settings = {
    for repo in var.github_repositories : repo.name => {

      #########################################################
      # Settings
      #########################################################

      name                        = repo.name
      description                 = repo.description
      homepage_url                = repo.homepage_url
      visibility                  = repo.visibility
      has_issues                  = repo.has_issues
      has_discussions             = repo.has_discussions
      has_projects                = repo.has_projects
      has_wiki                    = repo.has_wiki
      is_template                 = repo.is_template
      allow_rebase_merge          = repo.allow_rebase_merge
      allow_auto_merge            = repo.allow_auto_merge
      delete_branch_on_merge      = repo.delete_branch_on_merge
      web_commit_signoff_required = repo.web_commit_signoff_required
      auto_init                   = repo.auto_init
      gitignore_template          = repo.gitignore_template
      license_template            = repo.license_template
      archived                    = repo.archived
      archive_on_destroy          = repo.archive_on_destroy
      topics                      = repo.topics
      vulnerability_alerts        = repo.vulnerability_alerts
      pages                       = repo.pages
      security_and_analysis       = repo.security_and_analysis
      teams                       = repo.teams
      labels                      = repo.labels

      #########################################################
      # Settings (conditional)
      #########################################################

      # Squash settings
      allow_squash_merge          = repo.allow_squash_merge
      squash_merge_commit_title   = repo.allow_squash_merge == true ? repo.squash_merge_commit_title : null
      squash_merge_commit_message = repo.allow_squash_merge == true ? repo.squash_merge_commit_message : null

      # Merge settings
      allow_merge_commit   = repo.allow_merge_commit
      merge_commit_title   = repo.allow_merge_commit == true ? repo.merge_commit_title : null
      merge_commit_message = repo.allow_merge_commit == true ? repo.merge_commit_message : null
    }
  }

  # Rules are target-specific. A 'push' ruleset only supports file_path_restriction,
  # file_extension_restriction, max_file_path_length and max_file_size; every other rule belongs
  # to the 'branch' and 'tag' targets and is rejected by the GitHub API on a push ruleset.
  #
  # This yields one entry per offending push ruleset, naming the branch/tag-only rules it sets, so
  # the check block below can both assert on it and report it without duplicating the rule list.
  # Names are guarded here because a check block's error_message is evaluated eagerly and
  # interpolating a null hard-fails the plan.
  ruleset_push_rule_violations = [
    for entry in flatten([
      for repo in var.github_repositories : [
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) : {
          ruleset = "${repo.name == null ? "(unnamed)" : tostring(repo.name)}:${ruleset.name == null ? "(unnamed)" : tostring(ruleset.name)}"
          rules = [
            for rule in [
              { name = "creation", set = ruleset.rules.creation != null },
              { name = "deletion", set = ruleset.rules.deletion != null },
              { name = "non_fast_forward", set = ruleset.rules.non_fast_forward != null },
              { name = "required_linear_history", set = ruleset.rules.required_linear_history != null },
              { name = "required_signatures", set = ruleset.rules.required_signatures != null },
              { name = "update", set = ruleset.rules.update != null },
              { name = "update_allows_fetch_and_merge", set = ruleset.rules.update_allows_fetch_and_merge != null },
              { name = "pull_request", set = ruleset.rules.pull_request != null },
              { name = "copilot_code_review", set = ruleset.rules.copilot_code_review != null },
              { name = "required_status_checks", set = ruleset.rules.required_status_checks != null },
              { name = "required_deployments", set = ruleset.rules.required_deployments != null },
              { name = "merge_queue", set = ruleset.rules.merge_queue != null },
              { name = "required_code_scanning", set = ruleset.rules.required_code_scanning != null },
              { name = "branch_name_pattern", set = ruleset.rules.branch_name_pattern != null },
              { name = "tag_name_pattern", set = ruleset.rules.tag_name_pattern != null },
              { name = "commit_author_email_pattern", set = ruleset.rules.commit_author_email_pattern != null },
              { name = "commit_message_pattern", set = ruleset.rules.commit_message_pattern != null },
              { name = "committer_email_pattern", set = ruleset.rules.committer_email_pattern != null },
            ] : rule.name if rule.set
          ]
        } if ruleset.target == "push"
      ]
    ]) : entry if length(entry.rules) > 0
  ]
}