#!/bin/sh


openssl req -new -x509 -out rca.crt -days 3650 \
   -subj '/CN=root-ca.example.org/C=IT/ST=Roma/L=Roma/O=What/OU=Root' \
   -newkey rsa:2048 -nodes -keyout rca.key

openssl req -new -out ica.csr -days 3650 \
   -subj '/CN=intermediate-ca.example.org/C=IT/ST=Roma/L=Roma/O=What/OU=Interm' \
   -newkey rsa:2048 -nodes -keyout ica.key
openssl x509 -req -in ica.csr  -out ica.crt \
   -CA rca.crt -CAkey rca.key -CAcreateserial

openssl req -new -out srv.csr -days 3650 \
   -subj '/CN=srv.example.org/C=IT/ST=Roma/L=Roma/O=What/OU=Interm' \
   -newkey rsa:2048 -nodes -keyout srv.key
openssl x509 -req -in srv.csr  -out srv.crt \
   -CA ica.crt -CAkey ica.key -CAcreateserial

cat srv.crt ica.crt > srv-ica.chain.crt

sed -e 's/ srv.example.com//;/^127\.0\.0\.1/s/$/ srv.example.com/' \
   /etc/hosts > /etc/hosts.new
cat /etc/hosts.new > /etc/hosts

cat <<'END'

# Ready. Now:
#
# - run tmux
# - <CTRL-B "> to split the terminal in two
# - in one half, run `./start-server.sh`
# - <CTRL-B DOWN-ARROW> to move onto the other half
# - run `curl --cacert rca.crt https://srv.example.com:3000/`

END
