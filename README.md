# Terraform Modules for Google Cloud 

## Prerequistes

### Enable Following API's in Google cloud project

- Cloud SQL Admin API
- Cloud Run Admin API
- Cloud Identity-Aware Proxy API
- Cloud Resource Manager API
- Service Networking API
- Secret Manager API
- IAM API
- Compute Engine API
- Certificate Manager API
- Serverless VPC Access API

```
Note: Make sure to setup Cloud Build Pipeline first for terraform deployment. Detailed setup is given in 'Pipelines' folder
```

### Following resources need to be created prior terraform deployment

1. Service Accounts

- Following SA's will be created by security team

| Cloud Service  | IAM Roles |
| --- | --- |
| Cloud Build  | Cloud Build Service Account  <br>Cloud Build Service Agent<br>Cloud Deploy Operator<br>Cloud Run Admin<br>Cloud SQL Admin<br>Compute Admin<br>Compute Security Admin <br>Logs Writer<br>Monitoring Metric Writer<br>Serverless VPC Access Admin<br>Service Account User<br>Service Networking Admin<br>Service Usage Admin<br>Storage Object Admin  |
| Cloud Run  | Artifact Registry Administrator<br>Cloud Run Admin<br>ComputeNetwork Admin<br>Compute Viewer<br>Logs Writer<br>Monitoring Metric Writer<br>Secret Manager Secret Accessor<br>Secret Manager Viewer<br>Serverless VPC Access User<br>Service Account User<br>Service Networking Admin<br>Stackdriver Resource Metadata Writer<br>Storage Object Admin  |
|Infra Management | Logs Writer<br>Monitoring Metric Writer<br>Service Account User<br>Stackdriver Resource Metadata Writer |

2. Artifact Registry

- To achieve HA Two Artifact Registry will be created for Mumbai and Delhi region and Push latest copy of Gateway and Registry application on it.

3. Secret Manager

- All the applications components will be stored in the Secret manager. i.e. Application properties files.

4. GCS Bucket 

- To Store State of Terraform GCS Bucket will be used.
- To Store logs of Cloud Build pipeline

5. Static IP Adress

- Create Global External IP Address which will be used by Global Load Balancer.

6. Create SSL Certificates

- Make sure to have Certificate(.crt) and Private key(.pem) file to create Classic Google SSL Certificate from Certificate Manager.

```
Note: The above certificate should be combination of Root, Intermediate and Server certificate.
```