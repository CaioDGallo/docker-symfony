FROM ubuntu/apache2:latest

RUN apt-get update && apt-get install -y --no-install-recommends vim libapache2-mod-php8.1 libapache2-mod-php

WORKDIR /var/www

RUN a2enmod rewrite

CMD ["apache2-foreground"]

EXPOSE 80 443