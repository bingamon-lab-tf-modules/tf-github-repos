# Assert that team permissions are valid.
# Allowed values are:
# - "pull"
# - "triage"
# - "push"
# - "maintain"
# - "admin"
check "team_permissions" {
  assert {
    condition = alltrue(flatten([
      for repo in var.github_repositories : [
        for team in(repo.teams != null ? repo.teams : []) :
        contains(["pull", "triage", "push", "maintain", "admin"], team.permission)
      ]
    ]))
    error_message = <<EOT
One or more team permissions are invalid in the repository configurations.

Invalid permissions found in repositories: ${join(", ", [
    for repo in var.github_repositories :
    repo.name if length([
      for team in(repo.teams != null ? repo.teams : []) :
      team.permission if !contains(["pull", "triage", "push", "maintain", "admin"], team.permission)
    ]) > 0
])}

Allowed values are:
  - pull: Read and clone repositories. Open and comment on issues and pull requests.
  - triage: Read permissions plus manage issues and pull requests.
  - push: Triage permissions plus read, clone and push to repositories.
  - maintain: Write permissions plus manage issues, pull requests and some repository settings.
  - admin: Full access to repositories including sensitive and destructive actions.
    EOT
}
}

# Ensure that topics are valid or provide a nicer error message.
# Rules:
# - Only lowercase alphanumeric characters or hyphens
# - Cannot start with a hyphen
# - Must be 50 characters or less
# - No spaces allowed
check "topics" {
  assert {
    condition = alltrue([
      for repo in var.github_repositories :
      repo.topics == null ? true : length([
        for topic in repo.topics :
        topic if !(can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", topic)) && length(topic) <= 50)
      ]) == 0
    ])
    error_message = <<EOT
Invalid topics found in repository configurations.

Repositories with invalid topics: ${join(", ", [
    for repo in var.github_repositories :
    "${repo.name}: [${join(", ", [
      for topic in(repo.topics != null ? repo.topics : []) :
      "'${topic}'" if !(can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", topic)) && length(topic) <= 50)
      ])}]" if repo.topics != null && length([
      for topic in repo.topics :
      topic if !(can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", topic)) && length(topic) <= 50)
    ]) > 0
])}

Topic requirements:
  - Only lowercase alphanumeric characters or hyphens
  - Cannot start with a hyphen
  - Must be 50 characters or less
  - No spaces allowed

Examples of valid topics: terraform, landing-zone, infrastructure-as-code
    EOT
}
}

# Check for correct combinations of merge commit options.
# These are in the variable pairs: squash_merge_commit_title and squash_merge_commit_message
# Allowed combinations of values are:
# - PR_TITLE and PR_BODY
# - PR_TITLE and BLANK
# - PR_TITLE and COMMIT_MESSAGES
# - COMMIT_OR_PR_TITLE and COMMIT_MESSAGES
check "squash_merge_commit_options" {
  assert {
    condition = alltrue([
      for repo in var.github_repositories :
      (
        repo.squash_merge_commit_title == null ||
        repo.squash_merge_commit_message == null
        ) ? true : (
        # Valid combinations for squash merge
        (repo.squash_merge_commit_title == "PR_TITLE" && repo.squash_merge_commit_message == "PR_BODY") ||
        (repo.squash_merge_commit_title == "PR_TITLE" && repo.squash_merge_commit_message == "BLANK") ||
        (repo.squash_merge_commit_title == "PR_TITLE" && repo.squash_merge_commit_message == "COMMIT_MESSAGES") ||
        (repo.squash_merge_commit_title == "COMMIT_OR_PR_TITLE" && repo.squash_merge_commit_message == "COMMIT_MESSAGES")
      )
    ])
    error_message = <<EOT
Invalid squash merge commit settings combination found in repository configurations.

Repositories with invalid settings: ${join(", ", [
    for repo in var.github_repositories :
    "${repo.name} (title: ${repo.squash_merge_commit_title}, message: ${repo.squash_merge_commit_message})" if !(
      (repo.squash_merge_commit_title == null || repo.squash_merge_commit_message == null) ||
      (repo.squash_merge_commit_title == "PR_TITLE" && repo.squash_merge_commit_message == "PR_BODY") ||
      (repo.squash_merge_commit_title == "PR_TITLE" && repo.squash_merge_commit_message == "BLANK") ||
      (repo.squash_merge_commit_title == "PR_TITLE" && repo.squash_merge_commit_message == "COMMIT_MESSAGES") ||
      (repo.squash_merge_commit_title == "COMMIT_OR_PR_TITLE" && repo.squash_merge_commit_message == "COMMIT_MESSAGES")
    )
])}

Valid combinations:
  - PR_TITLE and PR_BODY
  - PR_TITLE and BLANK
  - PR_TITLE and COMMIT_MESSAGES
  - COMMIT_OR_PR_TITLE and COMMIT_MESSAGES
    EOT
}
}

# Check for correct combinations of merge commit options.
# These are in the variable pairs: merge_commit_title and merge_commit_message
# Allowed combinations of values are:
# - PR_TITLE and PR_BODY
# - PR_TITLE and BLANK
# - PR_TITLE and COMMIT_MESSAGES
# - COMMIT_OR_PR_TITLE and COMMIT_MESSAGES
check "merge_commit_options" {
  assert {
    condition = alltrue([
      for repo in var.github_repositories :
      (
        repo.merge_commit_title == null ||
        repo.merge_commit_message == null
        ) ? true : (
        # Valid combinations for regular merge
        (repo.merge_commit_title == "PR_TITLE" && repo.merge_commit_message == "PR_BODY") ||
        (repo.merge_commit_title == "PR_TITLE" && repo.merge_commit_message == "BLANK") ||
        (repo.merge_commit_title == "PR_TITLE" && repo.merge_commit_message == "COMMIT_MESSAGES") ||
        (repo.merge_commit_title == "COMMIT_OR_PR_TITLE" && repo.merge_commit_message == "COMMIT_MESSAGES")
      )
    ])
    error_message = <<EOT
Invalid merge commit settings combination found in repository configurations.

Repositories with invalid settings: ${join(", ", [
    for repo in var.github_repositories :
    "${repo.name} (title: ${repo.merge_commit_title}, message: ${repo.merge_commit_message})" if !(
      (repo.merge_commit_title == null || repo.merge_commit_message == null) ||
      (repo.merge_commit_title == "PR_TITLE" && repo.merge_commit_message == "PR_BODY") ||
      (repo.merge_commit_title == "PR_TITLE" && repo.merge_commit_message == "BLANK") ||
      (repo.merge_commit_title == "PR_TITLE" && repo.merge_commit_message == "COMMIT_MESSAGES") ||
      (repo.merge_commit_title == "COMMIT_OR_PR_TITLE" && repo.merge_commit_message == "COMMIT_MESSAGES")
    )
])}

Valid combinations:
  - PR_TITLE and PR_BODY
  - PR_TITLE and BLANK
  - PR_TITLE and COMMIT_MESSAGES
  - COMMIT_OR_PR_TITLE and COMMIT_MESSAGES
    EOT
}
}

# Validate web commit signoff setting
# When organization enforces commit signoff, repositories cannot disable it
check "web_commit_signoff_policy" {
  assert {
    condition = alltrue([
      for repo in var.github_repositories :
      repo.web_commit_signoff_required != false
    ])
    error_message = <<EOT
One or more repositories cannot disable web commit signoff when it's enforced by the organization.

Organization: ${var.github_organization_name}
Repositories with invalid settings: ${join(", ", [
    for repo in var.github_repositories :
    "${repo.name} (web_commit_signoff_required = ${repo.web_commit_signoff_required})" if repo.web_commit_signoff_required == false
])}

When organization policy enforces commit signoff, repositories must either:
  - Set web_commit_signoff_required = true (explicit)
  - Set web_commit_signoff_required = null (inherit from organization)
  - Remove web_commit_signoff_required from configuration (inherit from organization)
    EOT
}
}

# Assert that labels are valid.
# For each label, a name and color must be provided.
# Color must be a valid hex color code (6 characters, no #)
check "labels" {
  assert {
    condition = alltrue([
      for repo in var.github_repositories :
      repo.labels == null ? true : length([
        for label in repo.labels :
        label if label.name == null || label.color == null || label.name == "" || !can(regex("^[0-9a-fA-F]{6}$", label.color))
      ]) == 0
    ])
    error_message = <<EOT
Invalid labels found in repository configurations.

Repositories with invalid labels: ${join(", ", [
    for repo in var.github_repositories :
    "${repo.name}: [${join(", ", [
      for label in(repo.labels != null ? repo.labels : []) :
      "'${label.name}' (color: ${label.color})" if label.name == null || label.color == null || label.name == "" || !can(regex("^[0-9a-fA-F]{6}$", label.color))
      ])}]" if repo.labels != null && length([
      for label in(repo.labels != null ? repo.labels : []) :
      label if label.name == null || label.color == null || label.name == "" || !can(regex("^[0-9a-fA-F]{6}$", label.color))
    ]) > 0
])}

Label requirements:
  - name: Must be a non-empty string
  - color: Must be a valid 6-character hex color code (without #)

Examples of valid labels:
  - { name = "bug", color = "d73a4a" }
  - { name = "enhancement", color = "a2eeef" }
  - { name = "good first issue", color = "7057ff" }
    EOT
}
}

# Assert that rulesets are valid.
# Validate enforcement, target, and other required fields.
check "rulesets" {
  assert {
    condition = alltrue([
      for repo in var.github_repositories :
      repo.rulesets == null ? true : length([
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
        ruleset if(
          ruleset.name == null || ruleset.name == "" ||
          ruleset.enforcement == null || !contains(["disabled", "active", "evaluate"], ruleset.enforcement) ||
          ruleset.target == null || !contains(["branch", "tag", "push"], ruleset.target) ||
          ruleset.rules == null
        )
      ]) == 0
    ])
    error_message = <<EOT
Invalid rulesets found in repository configurations.

Repositories with invalid rulesets: ${join(", ", [
    for repo in var.github_repositories :
    "${repo.name}: [${join(", ", [
      for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
      "'${ruleset.name}'" if(
        ruleset.name == null || ruleset.name == "" ||
        ruleset.enforcement == null || !contains(["disabled", "active", "evaluate"], ruleset.enforcement) ||
        ruleset.target == null || !contains(["branch", "tag"], ruleset.target) ||
        ruleset.rules == null
      )
      ])}]" if repo.rulesets != null && length([
      for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
      ruleset if(
        ruleset.name == null || ruleset.name == "" ||
        ruleset.enforcement == null || !contains(["disabled", "active", "evaluate"], ruleset.enforcement) ||
        ruleset.target == null || !contains(["branch", "tag"], ruleset.target) ||
        ruleset.rules == null
      )
    ]) > 0
])}

Ruleset requirements:
  - name: Must be a non-empty string
  - enforcement: Must be one of "disabled", "active", "evaluate"
  - target: Must be one of "branch", "tag", "push"
  - rules: Must be defined (can be empty object)

Note: the file_path_restriction, file_extension_restriction, max_file_path_length and
max_file_size rules only apply to rulesets with the "push" target.

Examples of valid rulesets:
  - { name = "main-protection", enforcement = "active", target = "branch", rules = { required_linear_history = true } }
  - { name = "release-tags", enforcement = "active", target = "tag", rules = { deletion = false } }
    EOT
}
}

# Validate ruleset bypass actors
check "ruleset_bypass_actors" {
  assert {
    condition = alltrue(flatten([
      for repo in var.github_repositories : [
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) : [
          for actor in(ruleset.bypass_actors != null ? ruleset.bypass_actors : []) :
          contains(["RepositoryRole", "Team", "Integration", "OrganizationAdmin", "DeployKey", "EnterpriseOwner", "User"], actor.actor_type) &&
          contains(["always", "pull_request", "exempt"], actor.bypass_mode) &&
          (
            # OrganizationAdmin, EnterpriseOwner and DeployKey have no ID. The GitHub API
            # ignores actor_id for these types and this module omits it, so no ID is required.
            contains(["OrganizationAdmin", "EnterpriseOwner", "DeployKey"], actor.actor_type) ||
            (
              # Every other actor type must supply a numeric ID.
              actor.actor_id != null &&
              can(tonumber(actor.actor_id)) &&
              (
                (actor.actor_type == "RepositoryRole" && contains([2, 4, 5], actor.actor_id)) ||
                (actor.actor_type == "Team" && actor.actor_id > 0) ||
                (actor.actor_type == "Integration" && actor.actor_id > 0) ||
                (actor.actor_type == "User" && actor.actor_id > 0)
              )
            )
          )
        ]
      ]
    ]))
    error_message = <<EOT
Invalid bypass actors found in ruleset configurations.

Repositories with invalid bypass actors: ${join(", ", flatten([
    for repo in var.github_repositories : [
      for ruleset in(repo.rulesets != null ? repo.rulesets : []) : [
        for actor in(ruleset.bypass_actors != null ? ruleset.bypass_actors : []) :
        "${repo.name}:${ruleset.name} (type: ${actor.actor_type}, id: ${actor.actor_id == null ? "not set" : tostring(actor.actor_id)})" if !(
          contains(["RepositoryRole", "Team", "Integration", "OrganizationAdmin", "DeployKey", "EnterpriseOwner", "User"], actor.actor_type) &&
          contains(["always", "pull_request", "exempt"], actor.bypass_mode) &&
          (
            contains(["OrganizationAdmin", "EnterpriseOwner", "DeployKey"], actor.actor_type) ||
            (
              actor.actor_id != null &&
              can(tonumber(actor.actor_id)) &&
              (
                (actor.actor_type == "RepositoryRole" && contains([2, 4, 5], actor.actor_id)) ||
                (actor.actor_type == "Team" && actor.actor_id > 0) ||
                (actor.actor_type == "Integration" && actor.actor_id > 0) ||
                (actor.actor_type == "User" && actor.actor_id > 0)
              )
            )
          )
        )
      ]
    ]
]))}

Bypass actor requirements:
  - actor_type: Must be one of "RepositoryRole", "Team", "Integration", "OrganizationAdmin",
                "DeployKey", "EnterpriseOwner", "User"
  - bypass_mode: Must be one of "always", "pull_request", "exempt" (required)
  - actor_id: Must be a valid number for actor types that have an ID

Actor type ID mappings:
  - OrganizationAdmin: No ID - leave actor_id unset (ignored by the GitHub API)
  - EnterpriseOwner: No ID - leave actor_id unset (ignored by the GitHub API)
  - DeployKey: No ID - leave actor_id unset (ignored by the GitHub API)
  - RepositoryRole maintain: Must be 2
  - RepositoryRole write: Must be 4
  - RepositoryRole admin: Must be 5
  - Team: Must be a positive number (team ID)
  - Integration: Must be a positive number (GitHub App ID)
  - User: Must be a positive number (numeric GitHub user ID)
    EOT
}
}

# Validate ruleset merge queue settings
check "ruleset_merge_queue" {
  assert {
    condition = alltrue(flatten([
      for repo in var.github_repositories : [
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
        ruleset.rules.merge_queue == null ? true : (
          (ruleset.rules.merge_queue.grouping_strategy == null || contains(["ALLGREEN", "HEADGREEN"], ruleset.rules.merge_queue.grouping_strategy)) &&
          (ruleset.rules.merge_queue.merge_method == null || contains(["MERGE", "SQUASH", "REBASE"], ruleset.rules.merge_queue.merge_method))
        )
      ]
    ]))
    error_message = <<EOT
Invalid merge queue settings in ruleset configurations.

Merge queue requirements:
  - grouping_strategy: Must be one of "ALLGREEN", "HEADGREEN" (or null)
  - merge_method: Must be one of "MERGE", "SQUASH", "REBASE" (or null)
    EOT
  }
}

# Validate ruleset target pattern requirements
check "ruleset_target_patterns" {
  assert {
    condition = alltrue([
      for repo in var.github_repositories :
      length([
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
        ruleset if !(
          # When target is 'branch', branch_name_pattern is required
          (ruleset.target == "branch" ? ruleset.rules.branch_name_pattern != null : true) &&
          # When target is 'tag', tag_name_pattern is required
          (ruleset.target == "tag" ? ruleset.rules.tag_name_pattern != null : true)
        )
      ]) == 0
    ])
    error_message = <<EOT
Invalid ruleset target pattern configurations.

Ruleset target pattern requirements:
  - When target is "branch", branch_name_pattern must be specified
  - When target is "tag", tag_name_pattern must be specified

Repositories with invalid ruleset target patterns: ${join(", ", flatten([
    for repo in var.github_repositories : [
      for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
      "${repo.name}:${ruleset.name} (target: ${ruleset.target})" if !(
        (ruleset.target == "branch" ? ruleset.rules.branch_name_pattern != null : true) &&
        (ruleset.target == "tag" ? ruleset.rules.tag_name_pattern != null : true)
      )
    ]
]))}

Examples of valid ruleset configurations:

  # Branch-targeting ruleset (requires branch_name_pattern)
  rulesets = [
    {
      name        = "main-branch-protection"
      enforcement = "active"
      target      = "branch"
      rules = {
        branch_name_pattern = {
          operator = "starts_with"
          pattern  = "main"
        }
        required_linear_history = true
      }
    }
  ]

  # Tag-targeting ruleset (requires tag_name_pattern)
  rulesets = [
    {
      name        = "release-tag-protection"
      enforcement = "active"
      target      = "tag"
      rules = {
        tag_name_pattern = {
          operator = "starts_with"
          pattern  = "v"
        }
        deletion = false
      }
    }
  ]
    EOT
}
}

# Validate ruleset pattern rules operators
check "ruleset_pattern_operators" {
  assert {
    condition = alltrue(flatten([
      for repo in var.github_repositories : [
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) : [
          (ruleset.rules.branch_name_pattern == null || contains(["starts_with", "ends_with", "contains", "regex"], ruleset.rules.branch_name_pattern.operator)),
          (ruleset.rules.tag_name_pattern == null || contains(["starts_with", "ends_with", "contains", "regex"], ruleset.rules.tag_name_pattern.operator)),
          (ruleset.rules.commit_author_email_pattern == null || contains(["starts_with", "ends_with", "contains", "regex"], ruleset.rules.commit_author_email_pattern.operator)),
          (ruleset.rules.commit_message_pattern == null || contains(["starts_with", "ends_with", "contains", "regex"], ruleset.rules.commit_message_pattern.operator)),
          (ruleset.rules.committer_email_pattern == null || contains(["starts_with", "ends_with", "contains", "regex"], ruleset.rules.committer_email_pattern.operator))
        ]
      ]
    ]))
    error_message = <<EOT
Invalid pattern rule operators in ruleset configurations.

Pattern rule operator requirements:
  - operator: Must be one of "starts_with", "ends_with", "contains", "regex"
  - pattern: Must be a non-empty string

Note: Pattern rules (branch_name_pattern, tag_name_pattern, etc.) are only available for Enterprise repositories.
    EOT
  }
}

# Validate code scanning thresholds
check "ruleset_code_scanning_thresholds" {
  assert {
    condition = alltrue(flatten([
      for repo in var.github_repositories : [
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
        ruleset.rules.required_code_scanning == null ? true : length([
          for tool in ruleset.rules.required_code_scanning.required_code_scanning_tool :
          tool if !(
            contains(["none", "errors", "errors_and_warnings", "all"], tool.alerts_threshold) &&
            contains(["none", "critical", "high_or_higher", "medium_or_higher", "all"], tool.security_alerts_threshold)
          )
        ]) == 0
      ]
    ]))
    error_message = <<EOT
Invalid code scanning thresholds in ruleset configurations.

Code scanning threshold requirements:
  - alerts_threshold: Must be one of "none", "errors", "errors_and_warnings", "all"
  - security_alerts_threshold: Must be one of "none", "critical", "high_or_higher", "medium_or_higher", "all"
  - tool: Must be a non-empty string (name of the code scanning tool)
    EOT
  }
}

# Validate ruleset conditions
check "ruleset_conditions" {
  assert {
    condition = alltrue(flatten([
      for repo in var.github_repositories : [
        for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
        ruleset.conditions == null ? true : (
          # ref_name is required
          ruleset.conditions.ref_name != null &&
          # include is required and must be a non-empty list
          ruleset.conditions.ref_name.include != null &&
          length(ruleset.conditions.ref_name.include) > 0 &&
          # exclude is required (can be empty)
          ruleset.conditions.ref_name.exclude != null
        )
      ]
    ]))
    error_message = <<EOT
Invalid conditions found in repository ruleset configurations.

Repositories with invalid conditions: ${join(", ", flatten([
    for repo in var.github_repositories : [
      for ruleset in(repo.rulesets != null ? repo.rulesets : []) :
      "${repo.name}:${ruleset.name}" if !(
        ruleset.conditions == null || (
          ruleset.conditions.ref_name != null &&
          ruleset.conditions.ref_name.include != null &&
          length(ruleset.conditions.ref_name.include) > 0 &&
          ruleset.conditions.ref_name.exclude != null
        )
      )
    ]
]))}

Condition requirements:
  - ref_name: Required block
  - ref_name.include: Required list with at least one pattern
  - ref_name.exclude: Required list (can be empty)

Special patterns supported in include/exclude:
  - ~DEFAULT_BRANCH: Matches the repository's default branch
  - ~ALL: Matches all branches (only valid in include)

Examples:
  conditions = {
    ref_name = {
      include = ["main", "master"]
      exclude = ["feature/*"]
    }
  }

  conditions = {
    ref_name = {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }
    EOT
}
}

# GitHub Pages configuration.
# Validate build_type, cname, and source.
# build_type can be one of: workflow, legacy
# If build_type is legacy, source is required.
# If build_type is workflow, source should not be provided.
check "github_pages_configuration" {
  assert {
    condition = alltrue([
      for repo in var.github_repositories :
      repo.pages == null ? true : (
        repo.pages.build_type != null &&
        contains(["workflow", "legacy"], repo.pages.build_type) &&
        (repo.pages.build_type == "legacy" ? (
          repo.pages.source != null &&
          repo.pages.source.branch != null &&
          repo.pages.source.branch != "" &&
          repo.pages.source.path != null &&
          repo.pages.source.path != ""
        ) : true) &&
        (repo.pages.build_type == "workflow" ? repo.pages.source == null : true)
      )
    ])
    error_message = <<EOT
Invalid GitHub Pages configuration found in repository configurations.

Repositories with invalid GitHub Pages settings: ${join(", ", [
    for repo in var.github_repositories :
    repo.name if repo.pages != null ? !(
      repo.pages.build_type != null &&
      contains(["workflow", "legacy"], repo.pages.build_type) &&
      (
        repo.pages.build_type == "legacy" ?
        (
          repo.pages.source != null &&
          repo.pages.source.branch != null && repo.pages.source.branch != "" &&
          repo.pages.source.path != null && repo.pages.source.path != ""
        ) : true
      ) &&
      (
        repo.pages.build_type == "workflow" ?
        repo.pages.source == null : true
      )
    ) : false
])}

GitHub Pages configuration requirements:

  - build_type: Must be one of "workflow", "legacy"

  - For build_type "legacy":
    * source is required
    * source.branch must be a non-empty string
    * source.path must be a non-empty string

  - For build_type "workflow":
    * source must not be provided (should be null)

  - cname: Optional string for custom domain

Examples:
  # Workflow-based GitHub Pages (GitHub Actions)
  pages = {
    build_type = "workflow"
    cname      = "example.com"  # optional
  }

  # Legacy GitHub Pages (from branch)
  pages = {
    build_type = "legacy"
    cname      = "example.com"  # optional
    source = {
      branch = "main"
      path   = "/"
    }
  }
    EOT
}
}