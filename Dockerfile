FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOPATH=/root/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Install basic dependencies
RUN apt update && apt upgrade -y && \
    apt install -y python3 python3-pip python3-dev python3-setuptools \
    git curl wget unzip build-essential \
    default-jre nmap hydra ruby ruby-dev golang-go \
    libpcap-dev libcurl4-openssl-dev libssl-dev \
    ca-certificates jq net-tools dnsutils

# Install Node.js & npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt install -y nodejs

# Install sqlmap
RUN pip3 install sqlmap

# Install Dalfox (fixed)

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

# Set working dir
WORKDIR /app

# Copy project
COPY . .

# Install node dependencies
RUN npm install

# Start
CMD ["node", "index.js"]
