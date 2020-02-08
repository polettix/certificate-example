#!/bin/sh

openssl req -new -x509 -out rca.crt -days 42 \
   -subj '/CN=Everish Root CA/C=IT/ST=RM/L=Roma/O=Everish/OU=Root' \
   -newkey rsa:2048 -nodes -keyout rca.key

openssl req -new -out srv.csr -days 42 \
   -subj '/CN=srv.example.com/C=IT/ST=RM/L=Roma/O=Everish/OU=Server' \
   -newkey rsa:2048 -nodes -keyout srv.key

openssl x509 -req -in srv.csr  -out srv.crt \
   -CA rca.crt -CAkey rca.key -CAcreateserial

sed -e 's/ srv.example.com//;/^127\.0\.0\.1/s/$/ srv.example.com/' \
   /etc/hosts > /etc/hosts.new
cat /etc/hosts.new > /etc/hosts

cat <<'END'

Ready. Now:

- run tmux
- <CTRL-B "> to split the terminal in two
- in one half, run `./start-server.sh`
- <CTRL-B DOWN-ARROW> to move onto the other half
- run `curl --cacert rca.crt https://srv.example.com:3000/`

END
