FROM ubuntu:latest

RUN apt-get update -y

RUN apt-get upgrade -y



EXPOSE 80

# install nginx from mainline

WORKDIR /home

RUN apt install curl gnupg2 ca-certificates lsb-release -y

RUN echo "deb http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list

RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

RUN apt-key fingerprint ABF5BD827BD9BF62

RUN apt update -y && apt install nginx -y



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

COPY ./config/main.conf /etc/nginx/modsec/

# copy modsecurity on;

# copy /etc/nginx/nginx.conf

COPY ./config/nginx.conf /etc/nginx/

# unicode mapping

RUN mv /home/ModSecurity/unicode.mapping /etc/nginx/modsec/

# copy conf.d

COPY  ./config/default.conf /etc/nginx/conf.d/



WORKDIR /home

RUN wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.2.tar.gz

RUN tar -xzvf v3.0.2.tar.gz

RUN mv owasp-modsecurity-crs-3.0.2 /usr/local

WORKDIR /usr/local/owasp-modsecurity-crs-3.0.2

RUN cp crs-setup.conf.example crs-setup.conf

RUN cp /usr/local/owasp-modsecurity-crs-3.0.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/local/owasp-modsecurity-crs-3.0.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf

RUN cp /usr/local/owasp-modsecurity-crs-3.0.2/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example /usr/local/owasp-modsecurity-crs-3.0.2/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

RUN nginx -t

# install td-agent

RUN curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-bionic-td-agent3.sh | sed "s/sudo -k//g" | sed "s/sudo//g"|sh



RUN td-agent-gem install fluent-plugin-grep

RUN td-agent-gem install fluent-plugin-elasticsearch

COPY ./config/td-agent.conf /etc/td-agent/

# install php-fpm mysql



RUN apt install software-properties-common -y

RUN add-apt-repository ppa:ondrej/nginx-mainline

RUN add-apt-repository ppa:ondrej/php

RUN apt update



ENV TZ=Europe/Minsk

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 2 line above or ENV DEBIAN_FRONTEND=noninteractive 



RUN apt install php7.3-fpm php7.3-common php7.3-mysql php7.3-xml php7.3-xmlrpc php7.3-curl php7.3-gd php7.3-imagick php7.3-cli php7.3-dev php7.3-imap php7.3-mbstring php7.3-opcache php7.3-soap php7.3-zip unzip -yq
RUN apt install mysql-server -y

RUN service nginx start
RUN service php7.3-fpm start
RUN service td-agent start
#RUN service mysql start
RUN rm -rf /home/*

CMD ["service", "nginx","status"]
