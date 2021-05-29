FROM fedora:34
LABEL maintainer="CrazyMax"

ENV FAIL2BAN_VERSION="0.11.2" \
  TZ="UTC"

RUN dnf install --help
RUN dnf install -y \
    bash \
    curl \
    ipset \
    iptables \
    kmod \
    nftables \
    python3 \
    python3-setuptools \
    python3-systemd \
    ssmtp \
    2to3 \
    tzdata \
    vim \
    wget \
    unzip \
    whois \
    python3-pip \
  && pip3 install --upgrade pip \
  && pip3 install dnspython3 pyinotify \
  && cd /tmp \
  && curl -SsOL https://github.com/fail2ban/fail2ban/archive/${FAIL2BAN_VERSION}.zip \
  && unzip ${FAIL2BAN_VERSION}.zip \
  && cd fail2ban-${FAIL2BAN_VERSION} \
  && 2to3 -w --no-diffs bin/* fail2ban \
  && python3 setup.py install \
  && dnf remove -y python3-pip \
  && rm -rf /etc/fail2ban/jail.d /var/cache/apk/* /tmp/*

COPY entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1
