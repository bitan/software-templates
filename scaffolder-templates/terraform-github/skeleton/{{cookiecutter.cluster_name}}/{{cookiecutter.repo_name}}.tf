module "{{cookiecutter.repo_name}}" {
  source                  = "../../modules/github-repository"
  name                    = "{{cookiecutter.repo_name}}"
  description             = "{{cookiecutter.project_description}}"
  default_branch          = "main"
  team                   = "{{cookiecutter.github_team}}" 
  project                = "{{cookiecutter.repo_name}}"

  team_collaborators = [
    {
      team_id = data.github_team.{{cookiecutter.github_team}}.id,
      permission = "admin"
    }
    ,
    {
      team_id    = data.github_team.platform.id,
      permission = "push"
    }
    {%- if cookiecutter.db_reviewers -%}
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
          {%- if cookiecutter.prod_enabled %}
          "Terraform Cloud/glovo/{{cookiecutter.repo_name}}-prod",
          {%- endif -%}
          {%- if cookiecutter.pre_prod_enabled %}
          "Terraform Cloud/glovo/{{cookiecutter.repo_name}}-preprod",
          {%- endif -%}
          {%- if cookiecutter.stage_enabled %}
          "Terraform Cloud/glovo/{{cookiecutter.repo_name}}-stage",
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
  {% if cookiecutter.jenkins_webhook and cookiecutter.spinnaker_webhook -%}
  webhooks = [local.jenkins_webhook, local.spinnaker_webhook]
  {%- elif cookiecutter.jenkins_webhook and cookiecutter.spinnaker_webhook == false -%}
  webhooks = [local.jenkins_webhook]
  {%- elif cookiecutter.jenkins_webhook == false and cookiecutter.spinnaker_webhook -%}
  webhooks = [local.spinnaker_webhook]
  {% endif %}
}
