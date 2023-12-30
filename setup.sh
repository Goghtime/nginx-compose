#!/bin/bash

# Function to check and display errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    # Install prerequisites
    sudo apt-get update
    check_error "Failed to update apt"

    sudo apt-get install -y ca-certificates curl gnupg
    check_error "Failed to install prerequisites"

    sudo install -m 0755 -d /etc/apt/keyrings

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    check_error "Failed to add Docker's GPG key"

    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add Docker repository to Apt sources
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    check_error "Failed to add Docker repository"

    # Update Apt
    sudo apt-get update
    check_error "Failed to update apt"

    # Install Docker
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    check_error "Failed to install Docker"

    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker

    sudo usermod -aG docker $USER

    echo "Docker installed and started."
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    check_error "Failed to install Docker Compose"

    sudo chmod +x /usr/local/bin/docker-compose

    echo "Docker Compose installed."
else
    echo "Docker Compose is already installed."
fi

# Create necessary directories
mkdir -p ./conf.d ./cert ./logs

# Verify Docker and Docker Compose versions
docker --version
docker-compose --version

echo "Setup script completed."
