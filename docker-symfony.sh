#!/bin/bash

echo 'Welcome to the docker-symfony setup'

echo '' > ./docker/.env

PS3="Select the PHP version: "
PHP_VERSION='8.1'
SYMFONY_VERSION='6.1.*'
SERVER='nginx'
DATABASE='postgresql'
DATABASE_PORT='5432'

select lng in 8.1 8.0.2 7.2.5
do
    case $lng in
        "8.1")
            PHP_VERSION='8.1'
            break;;
        "8.0.2")
           PHP_VERSION='8.0.2'
           break;;
        "7.2.5")
           PHP_VERSION='7.2.5'
           break;;
        *)
    esac
done

PS3='Select the Symfony version: '
symfony_versions_options=()

if [ $PHP_VERSION = '8.1' ]; then
    symfony_versions_options=("v6.1.*" "v6.0.*" "v5.4.*")
fi

if [ $PHP_VERSION = '8.0.2' ]; then
    symfony_versions_options=("v6.0.*" "v5.4.*")
fi

if [ $PHP_VERSION = '7.2.5' ]; then
    symfony_versions_options=("v5.4.*")
fi

select opt in "${symfony_versions_options[@]}"
do
    case $opt in
        "v6.1.*")
            SYMFONY_VERSION="6.1.*"
            break;;
        "v6.0.*")
            SYMFONY_VERSION="6.0.*"
            break;;
        "v5.4.*")
            SYMFONY_VERSION="5.4.*"
            break;;
        *) echo "invalid option";;
    esac
done

PS3='Select the database: '
database_options=("PostgreSQL" "MySQL")

select opt in "${database_options[@]}"
do
    case $opt in
        "PostgreSQL")
            DATABASE="postgresql"
            break;;
        "MySQL")
            DATABASE="mysql"
            break;;
        *) echo "invalid option";;
    esac
done

PS3='Select the webserver: '
webserver_options=("Nginx" "Apache")

select opt in "${webserver_options[@]}"
do
    case $opt in
        "Nginx")
            SERVER="nginx"
            break;;
        "Apache")
            SERVER="apache"
            break;;
        *) echo "invalid option";;
    esac
done

read -p 'Do you wish to have a custom domain? e.g. dev.myproject.com  [y/n]' HAS_CUSTOM_DOMAIN

if [ $HAS_CUSTOM_DOMAIN = 'y' ]; then
    read -p 'Please type your custom domain: ' CUSTOM_DOMAIN
    sed -i "s/localhost/$CUSTOM_DOMAIN www.$CUSTOM_DOMAIN/" docker/nginx/sites/default.conf
fi

echo "APP_ENV=dev" >> ./docker/.env

if [ $DATABASE = 'postgresql' ]; then
    read -p 'What will be the database name: ' DATABASE_NAME
    read -p 'What will be the database password: ' DATABASE_PASSWORD

    echo "DATABASE_URL=\"postgresql://postgres:$DATABASE_PASSWORD@database-container:$DATABASE_PORT/$DATABASE_NAME?serverVersion=13&charset=utf8\"" >> ./docker/.env

    echo '' >> ./docker/docker-compose.yml
    echo '' >> ./docker/docker-compose.yml

    echo "  db:
    container_name: database-container
    image: postgres:12
    restart: always
    networks:
      - docker-symfony
    environment:
        POSTGRES_PASSWORD: $DATABASE_PASSWORD
        POSTGRES_DB: $DATABASE_NAME
    ports:
        - $DATABASE_PORT:$DATABASE_PORT
    volumes:
        - ./data/postgres:/var/lib/postgresql/data" >> ./docker/docker-compose.yml
fi

if [ $DATABASE = 'mysql' ]; then
    read -p 'What will be the database name: ' DATABASE_NAME
    read -p 'What will be the database password: ' DATABASE_PASSWORD
    read -p 'What will be the database user: ' MYSQL_USER
    read -p 'What will be the mysql root password: ' MYSQL_ROOT_PASSWORD
    
    DATABASE_PORT='3306'

    echo "DATABASE_URL=\"mysql://$MYSQL_USER:$DATABASE_PASSWORD@database-container:$DATABASE_PORT/$DATABASE_NAME?serverVersion=5.7\"" >> ./docker/.env

    echo '' >> ./docker/docker-compose.yml
    echo '' >> ./docker/docker-compose.yml

    echo "  db:
    container_name: database-container
    image: mysql:8.0.23
    platform: linux/x86_64
    networks:
      - docker-symfony
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - ./data/mysql:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
      - MYSQL_DATABASE=$DATABASE_NAME
      - MYSQL_USER=$MYSQL_USER
      - MYSQL_PASSWORD=$DATABASE_PASSWORD
    ports:
      - $DATABASE_PORT:$DATABASE_PORT"  >> ./docker/docker-compose.yml
fi

if [ $SERVER = 'nginx' ]; then
    echo '' >> ./docker/docker-compose.yml
    echo '' >> ./docker/docker-compose.yml

    echo "  nginx:
    container_name: server-container
    build:
      context: ./nginx
    networks:
      - docker-symfony
    volumes:
      - ./../src/:/var/www
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/sites/:/etc/nginx/sites-available
      - ./nginx/conf.d/:/etc/nginx/conf.d
      - ./logs:/var/log
    depends_on:
      - php-fpm
    ports:
      - \"80:80\"
      - \"443:443\"" >> ./docker/docker-compose.yml
fi

if [ $SERVER = 'apache' ]; then
    echo '' >> ./docker/docker-compose.yml
    echo '' >> ./docker/docker-compose.yml

    echo "  apache:
        container_name: server-container
        build:
          context: ./apache
        networks:
          - docker-symfony
        volumes:
          - ./../src/:/var/www
          - ./apache/vhost.conf:/etc/apache2/sites-enabled/000-default.conf
          - ./apache/apache2.conf:/etc/apache2/apache2.conf
          - ./logs/apache:/var/log/apache2
        depends_on:
          - php-fpm
        ports:
          - \"80:80\"
          - \"443:443\"" >> ./docker/docker-compose.yml
fi
      
echo '' >> ./docker/docker-compose.yml

echo "networks:
  docker-symfony:" >> ./docker/docker-compose.yml

read -p 'What is your Git email: ' GIT_EMAIL
read -p 'What is your Git name: ' GIT_NAME

echo "#!/bin/sh

git config --global user.email \"$GIT_EMAIL\"
git config --global user.name \"$GIT_NAME\"
symfony new /var/www --version=\"$SYMFONY_VERSION\" --webapp
composer i -o;
wait-for-it db:$DATABASE_PORT -- bin/console doctrine:migrations:migrate" > ./docker/php-fpm/setup-symfony-project.sh

echo "SYMFONY_VERSION="$SYMFONY_VERSION >> ./docker/.env
echo "PHP_VERSION="$PHP_VERSION >> ./docker/.env
echo "DATABASE="$DATABASE >> ./docker/.env
echo "SERVER="$SERVER >> ./docker/.env

cd docker
docker compose up --build