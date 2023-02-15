FROM ubuntu:jammy

RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends curl jq unzip ca-certificates php8.1-cli php8.1-curl php8.1-xml python3-pip \
    && cd /tmp \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && curl -L https://github.com/pantheon-systems/terminus/releases/download/3.1.3/terminus.phar --output terminus.phar \
    && chmod +x terminus.phar \
    && mv terminus.phar /usr/local/bin/terminus \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/apt/* \
    && rm -rf /var/log/dpkg.log \
    && rm -rf /var/log/bootstrap.log \
    && rm -rf /var/log/alternatives.log

ADD run.sh /run.sh

VOLUME ["/data"]
CMD ["/run.sh"]
