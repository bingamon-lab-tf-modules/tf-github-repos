# GitHub Organization data.
data "github_organization" "this" {
  name = var.github_organization_name
}
