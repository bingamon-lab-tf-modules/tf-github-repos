module "test" {
  source = "../module"

  github_enterprise_slug   = "acme-corp"
  github_organization_name = "acme-engineering"

  github_repositories = [
    {
      name        = "acme-engineering/acme-service"
      description = "This is a test repository"
      visibility  = "public"

      has_issues      = true
      has_discussions = true
      has_projects    = true
      has_wiki        = true

      is_template = false
    }
  ]
}
