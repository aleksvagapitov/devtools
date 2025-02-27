# Use the official Jenkins LTS image as a base
FROM jenkins/jenkins:lts

# Switch to root to install additional packages
USER root

# Install Docker CLI (no need for the full Docker Engine)
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli


# Install kubectl
RUN curl -LO "https://cdn.dl.k8s.io/release/$(curl -L -s https://cdn.dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Switch back to the jenkins user
USER jenkins