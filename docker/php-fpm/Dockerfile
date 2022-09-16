ARG PHP_VERSION
ARG SYMFONY_VERSION

FROM php:${PHP_VERSION}-fpm

ENV SYMFONY_VERSION_ENV $SYMFONY_VERSION

COPY wait-for-it.sh /usr/bin/wait-for-it

RUN chmod +x /usr/bin/wait-for-it

RUN apt-get update && \
    apt-get install -y --no-install-recommends libssl-dev zlib1g-dev curl git libapache2-mod-fcgid vim unzip netcat libxml2-dev libpq-dev libzip-dev && \
    pecl install apcu && \
    docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
    docker-php-ext-install -j$(nproc) zip opcache intl pdo_pgsql pdo_mysql pgsql && \
    docker-php-ext-enable apcu pdo_pgsql sodium && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY php-fpm-pool.conf 	/usr/local/etc/php/pool.d/www.conf

COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install symfony cli
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt install symfony-cli

WORKDIR /var/www

COPY setup-symfony-project.sh /usr/bin/setup-symfony-project

RUN chmod +x /usr/bin/setup-symfony-project

CMD setup-symfony-project ; php-fpm 

EXPOSE 9000