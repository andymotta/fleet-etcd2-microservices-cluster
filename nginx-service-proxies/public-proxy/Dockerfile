#-----------------------------------------------------------
# Dockerfile for Nginx Reverse Proxy
# Based on: https://www.digitalocean.com/community/tutorials/how-to-use-confd-and-etcd-to-dynamically-reconfigure-services-in-coreos
#-----------------------------------------------------------
FROM ubuntu:14.04.3

RUN \
  apt-get update && \
  apt-get install software-properties-common -y && \
  add-apt-repository ppa:nginx/stable -y && \
  apt-get update && \
  apt-get install nginx curl -y && \
  apt-get clean autoclean && \
  rm -rf /var/lib/apt/lists/*
RUN \
  cd /usr/local/bin && \
  curl -L https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64 -o confd && \
  chmod +x confd && \
  ln -sf /bin/bash /bin/sh

ADD nginx.toml /etc/confd/conf.d/
ADD nginx.tmpl /etc/confd/templates/
ADD nginx.conf /etc/nginx/
ADD confd-watch /usr/local/bin/
ADD index.html /usr/share/nginx/html/
ADD index.html /var/www/html/

RUN chmod +x /usr/local/bin/confd-watch
