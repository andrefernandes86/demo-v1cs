# Use a lightweight Ubuntu image as the base
FROM ubuntu:22.04

# Set environment variables to reduce interaction during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set default platform (overridden during build)
ARG TARGETPLATFORM

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    jq \
    unzip \
    python3 \
    python3-pip \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Conditional logic for platform-specific AWS CLI installation
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    else \
        echo "Unsupported platform: $TARGETPLATFORM" && exit 1; \
    fi && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install Azure CLI (common for all platforms)
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Python libraries for AWS and Azure scripting
RUN pip3 install --no-cache-dir boto3 azure-cli-core

# Create a working directory
WORKDIR /scripts

# Copy local scripts into the container
COPY ./scripts /scripts

# Set executable permissions for all scripts
RUN chmod +x /scripts/*

# Add the scripts directory to PATH
ENV PATH="/scripts:${PATH}"

# Default command to keep the container running
CMD ["/bin/bash"]
