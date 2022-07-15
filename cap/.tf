module "cap_repo" {
  source                  = "../../modules/github-repository"
  name                    = "cap_repo"
  description             = "yes"
  default_branch          = "main"
  team                   = "cap" 
  project                = "cap_repo"

  team_collaborators = [
    {
      team_id = data.github_team.cap.id,
      permission = "admin"
    }
    ,
    {
      team_id    = data.github_team.platform.id,
      permission = "push"
    },
    {
      team_id = data.github_team.livedb-stakeholders.id,
      permission = "pull"
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
          "Terraform Cloud/glovo/cap_repo-prod",
          "Terraform Cloud/glovo/cap_repo-stage",
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
  webhooks = [local.jenkins_webhook, local.spinnaker_webhook]
}
