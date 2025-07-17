FROM ubuntu:20.04

# Mengatur variabel lingkungan untuk instalasi non-interaktif dan lokasi Go
ENV DEBIAN_FRONTEND=noninteractive
ENV GOPATH=/root/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Memastikan direktori GOPATH/bin ada
RUN mkdir -p $GOPATH/bin

# Menginstal dependensi dasar
RUN apt update && apt upgrade -y && \
    apt install -y python3 python3-pip python3-dev python3-setuptools \
    git curl wget unzip build-essential \
    default-jre nmap hydra ruby ruby-dev golang-go \
    libpcap-dev libcurl4-openssl-dev libssl-dev \
    ca-certificates jq net-tools dnsutils

# Menginstal Node.js & npm (menggunakan cara yang lebih stabil)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt install -y nodejs

# Menginstal sqlmap
RUN pip3 install sqlmap

# Menginstal Nuclei
RUN GO111MODULE=on go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Menginstal Subfinder
RUN GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Menginstal FFUF
RUN GO111MODULE=on go install github.com/ffuf/ffuf@latest

# Menginstal WhatWeb
RUN gem install whatweb

# Menginstal Liffy
RUN git clone https://github.com/bcoles/liffy.git /opt/liffy && \
    chmod +x /opt/liffy/liffy.py && \
    ln -s /opt/liffy/liffy.py /usr/local/bin/liffy

# Mengatur direktori kerja
WORKDIR /app

# Menyalin proyek aplikasi Anda
COPY . .

# Menginstal dependensi Node.js
RUN npm install

# Memulai aplikasi
CMD ["node", "index.js"]
