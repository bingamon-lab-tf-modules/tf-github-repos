# Repository Labels
resource "github_issue_label" "this" {
  for_each = {
    for item in flatten([
      for repo in var.github_repositories : [
        for label in(repo.labels != null ? repo.labels : []) : {
          key         = "${repo.name}:${lower(replace(label.name, " ", "-"))}"
          repo_name   = repo.name
          label_name  = label.name
          color       = label.color
          description = label.description
        }
      ]
    ]) : item.key => item
  }

  repository  = each.value.repo_name
  name        = each.value.label_name
  description = try(each.value.description, null)
  color       = each.value.color

  depends_on = [
    github_repository.this
  ]
}
