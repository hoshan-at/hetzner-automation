FROM registry.access.redhat.com/ubi9/ubi-minimal

LABEL maintainer="Abdulrahman Alhoshan alhoshan.abdulrahman@gmail.com" \
      description="A minimal container to run Ansible based on Red Hat UBI 9."

# Install core dependencies using microdnf and clean up to keep the image small
RUN microdnf install -y \
    python3 \
    python3-pip \
    openssh-clients \
    git \
    gcc \
    python3-devel \
    sshpass \
    && microdnf clean all

# Upgrade pip and install Ansible and ansible-lint
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir ansible-core ansible-lint

# Set the default working directory inside the container
WORKDIR /ansible
