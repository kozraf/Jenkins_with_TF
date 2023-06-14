FROM jenkins/jenkins:lts
USER root
RUN apt-get update && \
    apt-get install -y software-properties-common curl gnupg && \
    curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg && \
    install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/ && \
    apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y && \
    apt-get update && \
    apt-get install terraform -y
# Copy Dockerfile into the image
COPY ./Dockerfile /Dockerfile
USER jenkins