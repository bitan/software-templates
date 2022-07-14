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
    {%- if values.db_reviewers == "yes" -%}
    ,
    {
      team_id = data.github_team.livedb-stakeholders.id,
      permission = "pull"
    }
    {%- endif %}
  ]
  branch_protections = [
    {
      pattern                = "main"
      enforce_admins         = false
      require_signed_commits = false
      required_status_checks = {
        strict   = true
        contexts = [
          {%- if values.prod_enabled == "yes" %}
          "Terraform Cloud/glovo/{{values.service_name}}-prod",
          {%- endif -%}
          {%- if values.stage_enabled == "yes" %}
          "Terraform Cloud/glovo/{{values.repo_name}}-stage",
          {%- endif %}
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
  {% if values.jenkins_webhook == "yes" and values.spinnaker_webhook == "yes" -%}
  webhooks = [local.jenkins_webhook, local.spinnaker_webhook]
  {%- elif values.jenkins_webhook == "yes" and values.spinnaker_webhook == "no" -%}
  webhooks = [local.jenkins_webhook]
  {%- elif values.jenkins_webhook == "no" and values.spinnaker_webhook == "yes" -%}
  webhooks = [local.spinnaker_webhook]
  {% endif %}
}
