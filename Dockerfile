FROM ubuntu:lastes
RUN apt-get update
RUN apt-get upgrade
# install nginx
RUN apt install curl gnupg2 ca-certificates lsb-release
RUN echo "deb http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
RUN apt-key fingerprint ABF5BD827BD9BF62
RUN apt update && apt install nginx
