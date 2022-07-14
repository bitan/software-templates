module "{{values.repo_name}}" {
  source                  = "../../modules/github-repository"
  name                    = "{{values.repo_name}}"
  description             = "{{values.project_description}}"
  default_branch          = "main"
  team                   = "{{values.github_team}}" 
  project                = "{{values.repo_name}}"

  team_collaborators = [
    {
      team_id = data.github_team.{{values.github_team}}.id,
      permission = "admin"
    }
    ,
    {
      team_id    = data.github_team.platform.id,
      permission = "push"
    }
  ]
  branch_protections = [
    {
      pattern                = "main"
      enforce_admins         = false
      require_signed_commits = false
      required_status_checks = {
        strict   = true
        contexts = [
          "continuous-integration/jenkins/pr-merge"
        ]
      }
      required_pull_request_reviews = {
        dismiss_stale_reviews           = true
        require_code_owner_reviews      = true
        required_approving_review_count = 2
      }
    }
  ]
  
}
