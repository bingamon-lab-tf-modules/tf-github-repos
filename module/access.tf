# Team Repository Access
resource "github_team_repository" "this" {
  for_each = {
    for team_repo in flatten([
      for repo in var.github_repositories : [
        for team in(repo.teams != null ? repo.teams : []) : {
          key        = "${repo.name}:${lower(replace(team.name, " ", "-"))}"
          repo_name  = repo.name
          team_slug  = lower(replace(team.name, " ", "-"))
          permission = team.permission
        }
      ]
    ]) : team_repo.key => team_repo
  }

  team_id    = var.github_team_data[each.value.team_slug].id
  repository = github_repository.this[each.value.repo_name].name
  permission = each.value.permission

  depends_on = [
    github_repository.this
  ]
}
