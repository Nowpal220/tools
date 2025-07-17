FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOPATH=/root/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN useradd -m -d /home/container container
STOPSIGNAL SIGINT

# Install basic dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y python python3 python3-pip python3-dev python3-setuptools \
    git curl wget unzip neofetch imagemagick build-essential \
    default-jre nmap hydra tini ruby ruby-dev \
    libpcap-dev libcurl4-openssl-dev libssl-dev \
    ca-certificates libgmp-dev jq net-tools dnsutils software-properties-common



RUN add-apt-repository ppa:longsleep/golang-backports -y && \
    apt update && \
    apt install -y golang-go

# Install Node.js & npm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s $(which node) /usr/local/bin/node \
    && ln -s $(which npm)  /usr/local/bin/npm \
    && npm install -g pm2

# Install sqlmap
RUN pip3 install sqlmap

# ✅ Install Dalfox (fixed)
RUN git clone https://github.com/hahwul/dalfox.git /opt/dalfox && \
    cd /opt/dalfox && \
    go build -o /usr/local/bin/dalfox .

# Install Nuclei
RUN go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest && \
    ln -s $GOPATH/bin/nuclei /usr/local/bin/nuclei

# Install Subfinder
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && \
    ln -s $GOPATH/bin/subfinder /usr/local/bin/subfinder

# Install FFUF
RUN go install github.com/ffuf/ffuf@latest && \
    ln -s $GOPATH/bin/ffuf /usr/local/bin/ffuf

# Install WhatWeb
RUN gem install whatweb

# Install Liffy
RUN git clone https://github.com/bcoles/liffy.git /opt/liffy && \
    ln -s /opt/liffy/liffy.py /usr/local/bin/liffy && chmod +x /opt/liffy/liffy.py


RUN npm install --global npm@latest typescript ts-node @types/node
RUN npm install -g pm2

RUN npm install -g corepack && corepack enable && corepack prepare pnpm@latest --activate


USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
