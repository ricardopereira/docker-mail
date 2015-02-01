docker-mail
==========

A mail server in a box.

"A secure, minimal-configuration mail server in a docker container" based on [lava/dockermail](https://github.com/lava/dockermail).

"This repository is tailored to small private servers, where you own some domain(s) and
want to receive the mail for and send mail from this domain. It consists of 2 separate docker containers:

 - **dovecot**: The SMTP and IMAP server with DKIM. This container uses postfix as MTA and dovecot as IMAP server.
    All incoming mail to your own domains is accepted. For outgoing mail, only authenticated (logged in with username and password)
    clients can send messages via STARTTLS on port 587. In theory it works with all mail clients, but it was only tested with Mail.app.

 - **mail-base**: This image is just an implementation detail. It is a workaround to allow sharing of configuration files between multiple docker images."


Setup
=====

###### You need to clone the repository or extract the source to a accessible docker machine.

1) Add all domains you want to receive mail for to the file `mail-base/domains`, like this:

    example.org
    example.net

2) Add user aliases to the file `mail-base/aliases`, like

    johndoe@example.org	        john.doe@example.org
    john.doe@example.org        john.doe@example.org
    admin@forum.example.org     forum-admin@example.org
    @example.net	        catch-all@example.net

An IMAP mail account is created for each entry on the right hand side.
Every mail sent to one of the addresses in the left column will
be delivered to the corresponding account in the right column.

3) Add user passwords to the file `mail-base/passwords` like this

    john.doe@example.org:{PLAIN}password123
    admin@example.org:{SHA256-CRYPT}$5$ojXGqoxOAygN91er$VQD/8dDyCYOaLl2yLJlRFXgl.NSrB3seZGXBRMdZAr6

To get the hash values, you can either install dovecot locally or use lxc-attach to attach to the running
container and run `doveadm pw -s SHA256-CRYPT` inside.

4) Add ssl certificate files to `dovecot/cert`.

 - cert.pem: ssl bundle
 - key.pem: private key

5) Change `MAILHOST` env variable from `dovecot/Dockerfile`.

  Change `opendkim.keys` file
  
  Change `opendkim.sign` file
  
  Change `opendkim.trusted` file

  Change `postfix.main.cf`:

    myhostname = example.com
    mydestination = mail.example.com

  Change `dovecot.lda`:

    hostname = example.com

6) Build containers:

    make

7) Copy DKIM string from output for domain service, something like

    `mail._domainkey.example.com v=DKIM1; k=rsa; p=<COPY_DKIM_STRING>`

8) Run container:

    make start

9) Stop container:

  Execute `docker ps` and get the id of the running container associated with the mail. Then `docker stop <pid>` to finish the container.


### Mail log

You can check on `/var/log`:

- mail.log: debug information and status.
- mail.err: critical errors.

Known issues
==============================
- Changing any configuration requires rebuilding the image and restarting the container
- No spam filter

