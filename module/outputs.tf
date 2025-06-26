output "repository_names" {
  description = "List of all repository names created by this module"
  value = [
    for repo_name, repo in github_repository.this : repo.name
  ]
}

output "repositories" {
  description = "Map of all repositories created by this module"
  value       = github_repository.this
}

output "labels" {
  description = "Map of all repository labels created by this module"
  value       = github_issue_label.this
}

output "rulesets" {
  description = "Map of all repository rulesets created by this module"
  value       = github_repository_ruleset.this
}
