#!/bin/sh

create_rca() {
   cat > rca.cnf <<'END'
[ ca ]
default_ca             = CA_default

[ CA_default ]
new_certs_dir          = .
database               = rca.x.database
serial                 = rca.x.serial
RANDFILE               = rca.x.RANDFILE
private_key            = rca.key
certificate            = rca.crt
default_md             = sha256
default_days           = 42
preserve               = no
policy                 = policy
copy_extensions        = copy

[ policy ]
countryName            = match
stateOrProvinceName    = match
organizationName       = match
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[ req ]
default_bits           = 2048
prompt                 = no
distinguished_name     = distinguished_name
string_mask            = utf8only
default_md             = sha256
x509_extensions        = rca_extensions

[ distinguished_name ]
countryName            = IT
stateOrProvinceName    = RM
localityName           = Roma
organizationName       = Everish
organizationalUnitName = Root
commonName             = Everish Root CA

[ rca_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical,CA:true
keyUsage               = critical,digitalSignature,cRLSign,keyCertSign

[ ica_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical,CA:true,pathlen:0
keyUsage               = critical,digitalSignature,cRLSign,keyCertSign
END
   openssl req -x509 -new -config rca.cnf -out rca.crt -days 42 \
      -newkey rsa:2048 -nodes -keyout rca.key
   touch rca.x.database
   printf "1000\n" > rca.x.serial
}

create_ica() {
   cat > ica.cnf <<'END'
[ ca ]
default_ca             = CA_default

[ CA_default ]
new_certs_dir          = .
database               = ica.x.database
serial                 = ica.x.serial
RANDFILE               = ica.x.RANDFILE
private_key            = ica.key
certificate            = ica.crt
default_md             = sha256
default_days           = 42
preserve               = no
policy                 = policy
copy_extensions        = copy

[ policy ]
countryName            = supplied
stateOrProvinceName    = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[ req ]
default_bits           = 2048
prompt                 = no
distinguished_name     = distinguished_name
string_mask            = utf8only
default_md             = sha256

[ distinguished_name ]
countryName            = IT
stateOrProvinceName    = RM
localityName           = Roma
organizationName       = Everish
organizationalUnitName = Intermediate
commonName             = Everish Intermediate CA

[ srv_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = CA:false
keyUsage               = critical,digitalSignature,keyEncipherment
END
   openssl req -new -config ica.cnf -out ica.csr -days 42 \
      -newkey rsa:2048 -nodes -keyout ica.key
   openssl ca -batch -config rca.cnf -extensions ica_extensions -days 42 \
      -in ica.csr -out ica.crt
   touch ica.x.database
   printf "1000\n" > ica.x.serial
}

create_srv() {
   cat > srv.cnf <<'END'
[ req ]
default_bits           = 2048
prompt                 = no
distinguished_name     = distinguished_name
string_mask            = utf8only
default_md             = sha256

[ distinguished_name ]
countryName            = IT
stateOrProvinceName    = RM
localityName           = Roma
organizationName       = Everish
organizationalUnitName = Server
commonName             = srv.example.com

[ extensions ]
subjectAltName         = DNS:localhost,DNS:srv.example.com
END
   openssl req -new -config srv.cnf -out srv.csr -days 42 \
      -reqexts extensions -newkey rsa:2048 -nodes -keyout srv.key
   openssl ca -batch -config ica.cnf -extensions srv_extensions -days 42 \
      -in srv.csr -out srv.crt
   cat srv.crt ica.crt > srv-ica.chain.crt
}

set_etc_hosts() {
   sed -e 's/ srv.example.com//;/^127\.0\.0\.1/s/$/ srv.example.com/' \
      /etc/hosts > /etc/hosts.new
   cat /etc/hosts.new > /etc/hosts
}

print_message() {
   cat <<'END'

# Ready. Now:
#
# - run tmux
# - <CTRL-B "> to split the terminal in two
# - in one half, run `./start-server.sh`
# - <CTRL-B DOWN-ARROW> to move onto the other half
# - run `curl --cacert rca.crt https://srv.example.com:3000/`

END
}


create_rca
create_ica
create_srv
set_etc_hosts
print_message
