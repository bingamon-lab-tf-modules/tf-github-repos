output "repository_names" {
  description = "List of all repository names created by this module"
  value = [
    for repo_name, repo in github_repository.this : repo.name
  ]
}

output "repositories" {
  description = "Map of all repositories created by this module"
  value = {
    for k, v in github_repository.this : k => {
      id                     = v.id
      name                   = v.name
      full_name              = v.full_name
      html_url               = v.html_url
      ssh_clone_url          = v.ssh_clone_url
      http_clone_url         = v.http_clone_url
      git_clone_url          = v.git_clone_url
      svn_url                = v.svn_url
      node_id                = v.node_id
      repo_id                = v.repo_id
      visibility             = v.visibility
      has_issues             = v.has_issues
      has_projects           = v.has_projects
      has_wiki               = v.has_wiki
      is_template            = v.is_template
      allow_merge_commit     = v.allow_merge_commit
      allow_squash_merge     = v.allow_squash_merge
      allow_rebase_merge     = v.allow_rebase_merge
      allow_auto_merge       = v.allow_auto_merge
      delete_branch_on_merge = v.delete_branch_on_merge
      topics                 = v.topics
    }
  }
}

output "labels" {
  description = "Map of all repository labels created by this module"
  value       = github_issue_label.this
}

output "rulesets" {
  description = "Map of all repository rulesets created by this module"
  value       = github_repository_ruleset.this
}
