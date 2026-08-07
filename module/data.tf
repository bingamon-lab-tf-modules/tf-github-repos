# Lookup the GitHub Organization details.
# tflint-ignore: terraform_unused_declarations
data "github_organization" "this" {
  name = var.github_organization_name
}
