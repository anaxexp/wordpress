#!/bin/bash

consul-template \
    -once \
    -dedup \
    -consul-addr ${CONSUL}:8500 \
    -template "/var/www/memcached-config.php.ctmpl:/var/www/memcached-config.php"