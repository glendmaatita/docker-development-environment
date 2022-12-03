FROM --platform=linux/x86_64 ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && \
    apt install -y wget jq software-properties-common \
    git curl apt-transport-https build-essential libpq-dev 

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Python
RUN add-apt-repository ppa:deadsnakes/ppa

# Install gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN apt update -y && \ 
    apt install -y terraform ansible python3-pip python3-distutils gcc xvfb git curl make google-cloud-cli vim

RUN pip install "cryptography==3.3.1"

WORKDIR /opt/build

# SSH
RUN apt install -y openssh-server \
	&& mkdir /var/run/sshd
COPY sshd_config /etc/ssh/sshd_config
ENTRYPOINT ["/opt/dev-env/init-env"]

# Customize environment
ARG USERNAME
ARG USERID
RUN useradd -m -u ${USERID} --shell /bin/bash ${USERNAME}

# Install poetry
ENV POETRY_HOME="/home/glend"
RUN curl -sSL https://install.python-poetry.org | python3
ENV PATH="/home/${USERNAME}/.local/bin:$PATH"

# NVM
RUN git clone https://github.com/creationix/nvm.git /opt/nvm \
	&& cd /opt/nvm \
	&& git checkout v0.39.2
    
# install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl