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
RUN curl -sfL https://github.com/k3s-io/k3s/releases/latest/download/k3s \
    -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Switch back to the jenkins user
USER jenkins
