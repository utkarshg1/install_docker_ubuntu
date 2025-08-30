#!/bin/bash

# Update the apt package index and install necessary packages
echo "Updating apt package index and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg

# Create keyrings directory if it doesn't exist
sudo mkdir -p /etc/apt/keyrings

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository to Apt sources
echo "Adding Docker repository to Apt sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update apt package index again with the new repository
echo "Updating apt package index with Docker repository..."
sudo apt-get update

# Install Docker Engine
echo "Installing Docker Engine..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Post-installation: Add current user to the 'docker' group
echo "Adding current user to the 'docker' group for non-root Docker management..."
sudo usermod -aG docker $USER

echo "Docker Engine installation complete."
echo "⚠️ Please log out and log back in (or run: newgrp docker) for the group changes to take effect."
echo "✅ You can verify installation by running: docker run hello-world"
