#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

[[ $- == *i* ]] && {
    # Prompt if interactive
    read -p "Are you sure you want to run the install script? (y)" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # Handle exits from shell or function but don't exit interactive shell.
    fi
}

if [ -z "$SUDO_USER" ]; then
    echo "Error: Invoke the script with sudo since script needs to install packages."
    exit 1
fi

# Only Ubuntu supported for now. 

CURR_DIR=$(pwd)
TMP_DIR="$( dirname -- "$0"; )"/.tmp
echo "Creating directory: " $TMP_DIR
mkdir -p $TMP_DIR
cd $TMP_DIR

echo "┌─────────────────────────────┐"
echo "│      INSTALL PACKAGES       │"
echo "└─────────────────────────────┘"

apt-get update

# Install packages
apt-get install -y \
    jq \
    libssl-dev \
    gettext-base \
    uuid \
    ca-certificates curl \
    clang \
    cmake \
    zlib1g-dev \
    libboost-dev \
    libboost-thread-dev

curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.54.2

echo "┌─────────────────────────────┐"
echo "│      INSTALL KUBECTL        │"
echo "└─────────────────────────────┘"

kubectl version --client=true >/dev/null 2>&1 || {
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

kubectl version --client=true -o json 2>/dev/null

# Installing kind
echo "┌─────────────────────────────┐"
echo "│      INSTALL KIND           │"
echo "└─────────────────────────────┘"

kind --version >/dev/null 2>&1 || {
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
    chmod +x ./kind
    mv ./kind /usr/local/bin/kind
}

kind --version

cd $CURR_DIR
echo "Deleting " $TMP_DIR
rm -rf $TMP_DIR

echo
echo "Excellent! Your prerequisites are installed 👍"
echo
