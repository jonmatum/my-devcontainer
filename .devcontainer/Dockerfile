FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install packages
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    gnupg \
    software-properties-common \
    bash \
    bash-completion \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add inside your .devcontainer/Dockerfile
RUN apt-get update && apt-get install -y docker.io

# Create docker group and add vscode user
RUN sudo groupadd -f docker && sudo usermod -aG docker vscode

# Create and fix workspace permissions
RUN mkdir -p /workspace && chown vscode:vscode /workspace

# Switch to workspace
WORKDIR /workspace

# Set default user
USER vscode

# Start container with bash safely
CMD [ "sleep", "infinity" ]