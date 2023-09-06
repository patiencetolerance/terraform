# Infrastructure Automation Pipeline for Terraform Deployment

## Pre-requistes

1. Install Cloud Build GitHub App on Github repository.<br>
Click here - [GitHub Cloud Build APP](https://github.com/apps/google-cloud-build)
2. Make sure to install above App on selected repositories only where Cloud build will be triggered.
3. Use GitHub Organization account to Add GitHub repositories to the 1st Gen Cloud Build Repositories.
4. Use asia-south1 Region to setup Cloud build pipeline.
5. Create Google Cloud Storage Bucket to store Cloud build logs and update the same in pipeline files.

## Pipeline Configuration

### Steps to configure Cloud Build Pipeline for terraform deployment

<br>

1. Pull Request Pipeline (Terraform Plan)

- Search for Cloud Build resource, Go to the triggers section.
- Click on Create New trigger and set <b>asia-south1</b> as region.
- Event that invokes trigger will be Pull request.
- Provide Respository name and branch name against which pull request will be created e.g.staging in Source block.
- Make sure to provide appropriate branch on which Pull request will be created.
- In Configuration block, select <b>Cloud Build configuration file (yaml or json)</b>.
- Add Cloud build YAML definition location. i.e. <i>/pipelines/env_name/cloudbuild_pull_request_push.yaml</i>
- Make sure to send Build logs to GitHub.
- Select the Cloud Build Custom Service Account which is created earlier.
- Finally Create the Trigger.

<br>

2. Merge Pipeline (Terraform Apply)

- Search for Cloud Build resource, Go to the triggers section.
- Click on Create New trigger and set <b>asia-south1</b> as region.
- Event that invokes trigger will be Push to Branch.
- Provide Respository name and branch name against which code will be merged e.g.staging in Source block.
- Make sure to provide appropriate branch on which code will be merged.
- In Configuration block, select <b>Cloud Build configuration file (yaml or json)</b>.
- Add Cloud build YAML definition location. i.e. <i>/pipelines/env_name/cloudbuild_pull_request_merge.yaml</i>
- Make sure to send Build logs to GitHub.
- Select the Cloud Build Custom Service Account which is created earlier.
- Finally Create the Trigger.

### Developer Guide

1. To add or remove any feature always create Feature branch with naming convention "feat/(jira_ticket_no)" and Pull request to be created against respective env branch. eg. staging.
2. After reviwed by the atleast 2 reviwers, it can be merged to the env branch e.g.staging.