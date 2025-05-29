#!/bin/bash

sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER

docker --version
docker-compose --version
echo "Please log out and log back in to apply the changes to your user group."
echo "You can also run 'newgrp docker' to apply the changes immediately."
echo "Docker installation complete. You can now run Docker commands without sudo."
echo "To verify Docker installation, run 'docker run hello-world'."
echo "For more information, visit https://docs.docker.com/get-started/overview/"
echo "Docker Compose installation complete. You can now use docker-compose commands."