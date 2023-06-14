# Summary

This is a simple Jenkins with TF deployment. Check Dockerfile to see how docker image is build.
This Jenkins deployment uses a single jenkins job to create remote backend for TFstate.

# How create jenkins+ TF for K8?

- prepare Dockerfile (as the one already that exists)
- install Docker
- launch

sudo docker build -t kozraf/jenkins-tf:1.0.5 .
sudo docker login
sudo docker push kozraf/jenkins-tf:1.0.5

- make sure that jenkins-deployment.yaml uses version of your jenkins Docker image

# TF state remote backend
A simple solution to keep TF state for remote backend for collaboration. 

## AWS creds

1. Install CloudBees AWS Credentials Plugin
2. Go to credentials and configore new credentials Dashboard -> Manage Jenkins -> and clicking on Global and then Add Credentials, fill AWS access key and secret key and make sure you will capture generated ID of the creds
Credentials
3. In pipeline - use following:

    environment {
        // Load AWS credentials
        AWS_CREDENTIALS = credentials('creds_ID_from_step_2')
    }
4. Check Jenkins file for more info    

## Outputs

- `bucket_id`: The ID of the created S3 bucket.
- `bucket_name`: The name of the created S3 bucket.
- `dynamodb_table_name`: The name of the created DynamoDB table.

These outputs are defined in the `outputs.tf` file.


## Jenkins

While creating jenkins pipeline - make sure you choose:

"This project is parameterized"

Name: 
- action

Choices:
- plan
- apply --auto-approve
- destroy --auto-approve
- state show (TF resource name goes here)
- state list