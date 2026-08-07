resource "github_repository" "this" {
  for_each = local.repositories_with_conditional_settings

  name         = each.value.name
  description  = each.value.description
  homepage_url = each.value.homepage_url
  visibility   = each.value.visibility

  has_issues      = each.value.has_issues
  has_discussions = each.value.has_discussions
  has_projects    = each.value.has_projects
  has_wiki        = each.value.has_wiki

  is_template = each.value.is_template

  allow_rebase_merge = each.value.allow_rebase_merge

  allow_auto_merge = each.value.allow_auto_merge

  allow_squash_merge          = each.value.allow_squash_merge
  squash_merge_commit_title   = each.value.squash_merge_commit_title
  squash_merge_commit_message = each.value.squash_merge_commit_message

  allow_merge_commit   = each.value.allow_merge_commit
  merge_commit_title   = each.value.merge_commit_title
  merge_commit_message = each.value.merge_commit_message

  delete_branch_on_merge = each.value.delete_branch_on_merge

  web_commit_signoff_required = each.value.web_commit_signoff_required

  auto_init = each.value.auto_init

  gitignore_template = each.value.gitignore_template
  license_template   = each.value.license_template

  archived           = each.value.archived
  archive_on_destroy = each.value.archive_on_destroy

  topics = each.value.topics

  vulnerability_alerts = each.value.vulnerability_alerts

  # GitHub Pages configuration
  dynamic "pages" {
    for_each = each.value.pages == null ? [] : [each.value.pages]
    content {
      # Source block is only included for legacy build type
      dynamic "source" {
        for_each = pages.value.build_type == "legacy" && pages.value.source != null ? [pages.value.source] : []
        content {
          branch = source.value.branch
          path   = source.value.path
        }
      }
      build_type = pages.value.build_type
      cname      = pages.value.cname
    }
  }

  # Security and analysis configuration
  dynamic "security_and_analysis" {
    for_each = each.value.security_and_analysis == null ? [] : [each.value.security_and_analysis]
    content {
      dynamic "advanced_security" {
        # Public repositories always have advanced security enabled and cannot be disabled.
        for_each = (each.value.visibility != "public" && security_and_analysis.value.advanced_security != null) ? [security_and_analysis.value.advanced_security] : []
        content {
          status = advanced_security.value.status
        }
      }
      dynamic "secret_scanning" {
        for_each = security_and_analysis.value.secret_scanning == null ? [] : [security_and_analysis.value.secret_scanning]
        content {
          status = secret_scanning.value.status
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = security_and_analysis.value.secret_scanning_push_protection == null ? [] : [security_and_analysis.value.secret_scanning_push_protection]
        content {
          status = secret_scanning_push_protection.value.status
        }
      }
    }
  }

  lifecycle {
    # `template` records the repository a repo was CREATED FROM. GitHub exposes it
    # as `template_repository` on reads, but its repository update API has no
    # field for it - it is create-time-only and immutable thereafter.
    #
    # This module has no `template` input, so for any repo created from a template
    # (or adopted by import) the provider reads the block back, finds nothing in
    # configuration, and plans to remove it. The apply cannot actually remove it,
    # so the identical diff returns on every subsequent plan.
    #
    # Observed in bingamon-lab-tf-modules, where the four repositories created
    # from tf-template reported "4 to change" on every plan and were left
    # unchanged by applying.
    #
    # Ignoring it is correct rather than a workaround - the attribute is not
    # manageable, so there is no state this module could converge it to. Adding a
    # `template` input would not fix it either: that would only take effect at
    # creation and would still leave imported repos drifting forever.
    ignore_changes = [
      template,
    ]
  }

  depends_on = [
    data.github_organization.this
  ]
}
