#!/bin/bash

sed -i '/规则/d' /etc/nginx/conf.d/default.conf
sed -i '/limit_except/d; /ssl_ciphers/d; /ssl_prefer_server_ciphers/d' /etc/nginx/conf.d/default.conf
line_number=$(grep -n "ssl_protocols  TLSv1.2;" /etc/nginx/conf.d/default.conf | cut -d ':' -f 1)
sed -i "$((line_number+1)),$((line_number+3))d; /location ~* \s(\.(svn|git|sql|bak|old|tar|gz|tgz|zip|7z|rar|DS_store)$)/d" /etc/nginx/conf.d/default.conf

sudo systemctl restart nginx