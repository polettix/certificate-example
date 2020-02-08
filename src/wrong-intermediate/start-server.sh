#!/bin/sh

perl -I /app/local/lib/perl5 ../sample-server.pl daemon \
   -l 'https://*:3000?cert=./srv-ica.chain.crt&key=./srv.key'
