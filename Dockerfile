FROM alpine:3.12

RUN apk update && \
    apk add bash git openssh augeas shadow rsync rssh && \
    deluser $(getent passwd 33 | cut -d: -f1) && \
    delgroup $(getent group 33 | cut -d: -f1) 2>/dev/null || true && \
    mkdir -p ~root/.ssh /etc/authorized_keys && chmod 700 ~root/.ssh/ && \
    augtool 'set /files/etc/ssh/sshd_config/AuthorizedKeysFile ".ssh/authorized_keys /etc/authorized_keys/%u"' && \
    augtool 'set /files/etc/ssh/sshd_config/ChallengeResponseAuthentication no' && \
    augtool 'set /files/etc/ssh/sshd_config/AllowStreamLocalForwarding no' && \
    augtool 'set /files/etc/ssh/sshd_config/X11Forwarding no' && \
    augtool 'set /files/etc/ssh/sshd_config/PermitTTY no' && \
    augtool 'set /files/etc/ssh/sshd_config/LoginGraceTime 20' && \
    echo -e "Port 22\n" >> /etc/ssh/sshd_config && \
    cp -a /etc/ssh /etc/ssh.cache && \
    rm -rf /var/cache/apk/*

EXPOSE 22

COPY entry.sh /entry.sh

VOLUME [ "/etc/ssh/", "/etc/authorized_keys/" ]

ENTRYPOINT ["/entry.sh"]

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
