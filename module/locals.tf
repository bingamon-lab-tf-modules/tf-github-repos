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
      has_downloads               = repo.has_downloads
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
}