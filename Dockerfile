# Build SafeNetwork Docker container
FROM alpine:3.14
LABEL version="1.0"
LABEL maintainer="Folât Pjêrsômêj"
LABEL release-date="2021-07-20"

# Update and install dependencies
RUN apk update && apk add \
    bash \
    curl \
    jq
    
# Create safe folders
RUN mkdir -p ~/.safe/{node,cli}

# Install the safe network node
RUN curl -L $(curl --silent https://api.github.com/repos/maidsafe/safe_network/releases/latest | \
    jq --arg PLATFORM_ARCH "$(echo `uname -m`)" \
    -r '.assets[] | select(.name | endswith($PLATFORM_ARCH+"-unknown-linux-musl.tar.gz")).browser_download_url') | \
    tar xz -C ~/.safe/node

# Install the safe network command line interface
RUN curl -L $(curl --silent https://api.github.com/repos/maidsafe/sn_cli/releases/latest | \
    jq --arg PLATFORM_ARCH "$(echo `uname -m`)" \
    -r '.assets[] | select(.name | endswith($PLATFORM_ARCH+"-unknown-linux-musl.tar.gz")).browser_download_url') | \
    tar xz -C ~/.safe/

# Make profile file with exported PATH and refresh the shell (while building)
SHELL ["/bin/bash", "--login", "-c"]
RUN echo 'export PATH=$PATH:/root/.safe/cli' > ~/.profile && source ~/.profile

# Set ENV PATH (after build will be used to find the safe node command)
ENV PATH=$PATH:/root/.safe

# Add the fleming test network
RUN safe networks add fleming-testnet https://sn-node.s3.eu-west-2.amazonaws.com/config/node_connection_info.config
RUN safe networks switch fleming-testnet

# Join the safe network
RUN safe node join

# Expose PORT of the node 
EXPOSE 12000

# Launch safe on Docker command
CMD ["safe"]
