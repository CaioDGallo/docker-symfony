FROM nginx:alpine

RUN apk --update add ca-certificates

RUN apk add openssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
    -out /etc/ssl/certs/ssl-cert-snakeoil.pem \
    -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=localhost"

WORKDIR /var/www

CMD ["nginx"]

EXPOSE 80 443