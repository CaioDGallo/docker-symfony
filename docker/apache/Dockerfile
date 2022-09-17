FROM ubuntu/apache2:latest

RUN apt-get update && apt-get install -y --no-install-recommends vim libapache2-mod-php8.1 libapache2-mod-php openssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
    -out /etc/ssl/certs/ssl-cert-snakeoil.pem \
    -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=localhost"

RUN a2enmod rewrite \
    && a2enmod ssl \
    && a2enmod headers \
    && a2enmod expires

WORKDIR /var/www

CMD ["apache2-foreground"]

EXPOSE 80 443