FROM debian:latest

ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y -qq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    gnupg-agent \
    jq \
    lsb-release \
    python3 \
    python3-pip \
    rsync \
    software-properties-common \
    tar \
    wget \
    zip

# Docker apt repo
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli

# https://www.mkdocs.org/
RUN pip3 install --no-cache --upgrade pip setuptools
# https://github.com/jreese/markdown-pp
RUN pip3 install mkdocs MarkdownPP

COPY preprocessor.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/preprocessor.sh

EXPOSE 8000
