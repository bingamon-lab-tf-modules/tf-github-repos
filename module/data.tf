# Lookup the GitHub Enterprise details.
# tflint-ignore: terraform_unused_declarations
data "github_enterprise" "this" {
  slug = var.github_enterprise_slug
}

# Lookup the GitHub Organization details.
# tflint-ignore: terraform_unused_declarations
data "github_organization" "this" {
  name = var.github_organization_name
}
