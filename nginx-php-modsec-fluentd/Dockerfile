FROM ubuntu:latest
RUN apt-get update
RUN apt-get upgrade

EXPOSE 80
# install nginx from mainline
WORKDIR /home
RUN apt install curl gnupg2 ca-certificates lsb-release
RUN echo "deb http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
RUN apt-key fingerprint ABF5BD827BD9BF62
RUN apt update && apt install nginx

# install modsec

RUN apt-get install -y apt-utils autoconf automake build-essential git libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libtool libxml2-dev libyajl-dev pkgconf wget zlib1g-dev
RUN git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
WORKDIR /home/ModSecurity
RUN git submodule init; git submodule update;./build.sh;./configure;make;make install
WORKDIR /home
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
# kiem tra phien ban nginx: nginx -v
RUN wget http://nginx.org/download/nginx-1.17.6.tar.gz
RUN tar zxvf nginx-1.17.6.tar.gz
WORKDIR /home/nginx-1.17.6
RUN ./configure --with-compat --add-dynamic-module=../ModSecurity-nginx
RUN make modules
RUN cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules
RUN mkdir /etc/nginx/modsec
RUN wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
RUN mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
RUN sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf

# copy /etc/nginx/modsec/main.conf
COPY ./conf/main.conf /etc/nginx/modsec/
# copy modsecurity on;
# copy /etc/nginx/nginx.conf
COPY ./conf/nginx.conf /etc/nginx/
# unicode mapping
RUN mv /home/ModSecurity/unicode.mapping /etc/nginx/modsec/
# copy conf.d
COPY  ./conf/default.conf /etc/nginx/conf.d/

WORKDIR /home
RUN wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.2.tar.gz
RUN tar -xzvf v3.0.2.tar.gz
RUN sudo mv owasp-modsecurity-crs-3.0.2 /usr/local
WORKDIR /usr/local/owasp-modsecurity-crs-3.0.2
RUN cp crs-setup.conf.example crs-setup.conf
RUN cp /usr/local/owasp-modsecurity-crs-3.0.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/local/owasp-modsecurity-crs-3.0.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
RUN cp /usr/local/owasp-modsecurity-crs-3.0.2/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example /usr/local/owasp-modsecurity-crs-3.0.2/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf
RUN nginx -s reload
# install td-agent
RUN curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-bionic-td-agent3.sh | sh
RUN td-agent-gem install fluent-plugin-elasticsearch
COPY ./conf/td-agent.conf /etc/td-agent/
# install php-fpm

RUN sudo apt install php7.3 php7.3-fpm 

RUN rm -rf /home/*

CMD [ "systemctl status nginx" ]