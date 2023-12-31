# Jenkins with Terraform on Kubernetes

This repository provides resources and configurations for deploying Jenkins integrated with Terraform on a Kubernetes cluster. The deployment utilizes NFS for persistent storage, ensuring data longevity across pod restarts. This Jenkins deployment uses a single job to create a remote backend for Terraform state, offering a straightforward solution to maintain the Terraform state remotely for collaboration.

## Components

1. **Dockerfile**: Outlines the creation of a custom Jenkins Docker image with Terraform installed. Check the Dockerfile to see the specifics of how the Docker image is built.
2. **Kubernetes Configurations**: Includes deployment (for deploying a Jenkins pod), service (to expose Jenkins on a NodePort for external access), persistent volume (PV) and persistent volume claim (PVC) (for ensuring Jenkins data is stored persistently using NFS), and StorageClass (defining NFS as the storage backend).
3. **Shell Script**: A utility to automate the deployment process and provide real-time feedback.
4. **Sample Jenkins Pipeline**: Illustrates the integration of Jenkins with Terraform and AWS.

## How to test it quickly?

Well - try my https://github.com/kozraf/RafK8clstr which is an 3-node K8 cluster deployed using Vagrant and it will
allow you to deploy content of this repo using a simple setup.bat file. However - if you want to deploy it on your
K8 cluster - read further. 

## Setup and Deployment

1. **Docker Setup**:
   - Prepare the Dockerfile (as provided in this repository).
   - Install Docker.
   - Build the Docker image using the command:
     ```bash
     sudo docker build -t kozraf/jenkins-tf:1.0.5 .
     sudo docker login
     sudo docker push kozraf/jenkins-tf:1.0.5
     ```
   - Ensure that `jenkins-deployment.yaml` uses the correct version of your Jenkins Docker image.

2. **Kubernetes Deployment**:
   - Use the provided shell script `jenkins_install.sh` to automate the deployment process.
   - Alternatively, apply the Kubernetes configurations manually using `kubectl apply -f <filename>`.

3. **Accessing Jenkins**:
   - After deployment, Jenkins can be accessed using any node's IP address and port `30000`.
   - Retrieve the initial Jenkins admin password using the command provided in the script output.

4. **Terraform State Remote Backend**:
   - A simple solution to store the Terraform state for a remote backend for collaboration. 

5. **AWS Credentials Setup in Jenkins**:
   - Install the AWS Credentials Plugin (https://plugins.jenkins.io/aws-credentials/).
   - Configure new credentials in Jenkins by navigating to Dashboard -> Manage Jenkins -> Global and then "Add Credentials". Enter your AWS access key and secret key. ID will be generated automatically.
   - Make sure to note the generated ID of the credentials.
   - In your Jenkins pipeline, use the following snippet to load AWS credentials:
     ```bash
     environment {
         // Load AWS credentials
         AWS_CREDENTIALS = credentials('creds_ID_from_previous_step')
     }
     ```
   - Check the provided Jenkins file (sample-pipeline.txt) for more details.

6. **Jenkins Pipeline Configuration**:
   - Logon to Jenkins
   - Choose "Create a new Item"
   - Choose "Pipeline" and add a name
   - Scroll down and select "This project is parameterized", then "Choice Parameter" and fill accordingly:
   - For name choose `action` (lowercase!!!), then in "Choices" copy below:
     - plan
     - apply --auto-approve
     - destroy --auto-approve
     - state show (Provide Terraform resource name here)
     - state list
   - On the bottom choose "pipeline script" and copy content of sample-pipeline.txt
   - Click Save
 
7. **Jenkins Pipeline usage**

    - Open newly created Jenkins project
    - Choose Build with Parameters
    - Choose "plan" as action
    - Hit "Build"
    - Wait till "plan" build will finish
    - Review Console Output
    - Choose Build with Parameters
    - Choose "apply --auto-approve" as action
    - Hit "Build"
    - Wait till "plan" build will finish
    - Review Console Output
    - Confirm that S3 bucket and DynamoDB are build

## Contributing

Feel free to raise issues or submit pull requests if you find areas of improvement or encounter bugs.

## License

The scripts, configurations, and documentation in this project are licensed under the MIT License. This license applies only to the scripts, configurations, and documentation contained in this repository and not to the software they interact with.

