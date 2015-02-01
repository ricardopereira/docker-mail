all: mail-base dovecot

.PHONY: mail-base dovecot run-dovecot

mail-base: 
	cd mail-base; docker build --no-cache -t mail-base .

dovecot: mail-base
	cd dovecot; docker build -t dovecot:2.1.7 .

run-dovecot:
	docker run -d -v /var/log:/var/log -p 0.0.0.0:25:25 -p 0.0.0.0:587:587 -p 0.0.0.0:143:143 -v /srv/vmail:/srv/vmail dovecot:2.1.7

start: run-dovecot