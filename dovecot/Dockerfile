FROM mail-base

# Pre-requisites
RUN apt-get update

# Install self-signed ssl certs
RUN apt-get install -y --force-yes ssl-cert

# Install postfix as MTA
RUN apt-get install -y --force-yes postfix

# Install dovecot as IMAP server
RUN apt-get install -y --force-yes dovecot-imapd

# Install DKIM
RUN apt-get install -y --force-yes opendkim
RUN apt-get install -y --force-yes opendkim-tools

# Hostname of mail server
ENV MAILHOST example.com

# Certificate
ADD ./cert/cert.pem /srv/cert/cert.pem
ADD ./cert/key.pem /srv/cert/key.pem

# postfix configuration
RUN echo $MAILHOST > /etc/mailname
ADD ./postfix.main.cf /etc/postfix/main.cf
ADD ./postfix.master.cf.append /etc/postfix/master-additional.cf
RUN cat /etc/postfix/master-additional.cf >> /etc/postfix/master.cf

# configure mail delivery to dovecot
RUN cp /aliases /etc/postfix/virtual
RUN cp /domains /etc/postfix/virtual-mailbox-domains

# todo: this could probably be done in one line
RUN mkdir /etc/postfix/tmp; awk < /etc/postfix/virtual '{ print $2 }' > /etc/postfix/tmp/virtual-receivers
RUN sed -r 's,(.+)@(.+),\2/\1/,' /etc/postfix/tmp/virtual-receivers > /etc/postfix/tmp/virtual-receiver-folders
RUN paste /etc/postfix/tmp/virtual-receivers /etc/postfix/tmp/virtual-receiver-folders > /etc/postfix/virtual-mailbox-maps

# map virtual aliases and user/filesystem mappings
RUN postmap /etc/postfix/virtual
RUN postmap /etc/postfix/virtual-mailbox-maps

# add user vmail who own all mail folders
RUN groupadd -g 5000 vmail
RUN useradd -g vmail -u 5000 vmail -d /srv/vmail -m
RUN chown -R vmail:vmail /srv/vmail
RUN chmod u+w /srv/vmail

# dovecot configuration
ADD ./dovecot.mail /etc/dovecot/conf.d/10-mail.conf
ADD ./dovecot.ssl /etc/dovecot/conf.d/10-ssl.conf
ADD ./dovecot.auth /etc/dovecot/conf.d/10-auth.conf
ADD ./dovecot.master /etc/dovecot/conf.d/10-master.conf
ADD ./dovecot.lda /etc/dovecot/conf.d/15-lda.conf
ADD ./dovecot.imap /etc/dovecot/conf.d/20-imap.conf
# add verbose logging
#ADD ./internal/dovecot.logging /etc/dovecot/conf.d/10-logging.conf

# Add password file
RUN cp /passwords /etc/dovecot/passwd

# OpenDKIM configuration
ADD ./opendkim.conf /etc/opendkim.conf
ADD ./opendkim.default.append /etc/default/opendkim.additional
RUN cat /etc/default/opendkim.additional >> /etc/default/opendkim
RUN mkdir /etc/opendkim
RUN mkdir /etc/opendkim/keys
ADD ./opendkim.trusted /etc/opendkim/TrustedHosts
ADD ./opendkim.keys /etc/opendkim/KeyTable
ADD ./opendkim.sign /etc/opendkim/SigningTable
RUN mkdir /etc/opendkim/keys/$MAILHOST
RUN opendkim-genkey -s mail -d $MAILHOST
RUN chown opendkim:opendkim mail.private
RUN mv mail.txt /etc/opendkim/keys/$MAILHOST/
RUN mv mail.private /etc/opendkim/keys/$MAILHOST/
RUN chown -R opendkim:opendkim /etc/opendkim/keys
RUN echo 'DKIM done'
RUN cat /etc/opendkim/keys/$MAILHOST/mail.txt

# i'm not sure what expose actually does, so its mainly here for documentation
# smtp port for incoming mail
EXPOSE 25 
# imap port
EXPOSE 143
# smtp port for outgoing
EXPOSE 587

# todo: enable port 587 for outgoing mail, separate ports 25 and 587
# http://www.synology-wiki.de/index.php/Zusaetzliche_Ports_fuer_Postfix

# start necessary services for operation (dovecot -F starts dovecot in the foreground to prevent container exit)
ENTRYPOINT chown -R vmail:vmail /srv/vmail; service rsyslog start; service postfix start; service opendkim start; dovecot -F
