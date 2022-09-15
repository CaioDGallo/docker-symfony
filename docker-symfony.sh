#!/bin/bash

echo 'Welcome to the docker-symfony setup'

echo '' > ./docker/.env

PS3="Select the PHP version: "
PHP_VERSION='8.1'
SYMFONY_VERSION='6.1.*'
SERVER='nginx'
DATABASE='postgresql'

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

read -p 'What will be the database name: ' DATABASE_NAME
read -p 'What will be the database password: ' DATABASE_PASSWORD

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

echo "APP_ENV=dev" >> ./docker/.env

if [ $DATABASE = 'postgresql' ]; then
    echo "DATABASE_URL=\"postgresql://postgres:$DATABASE_PASSWORD@database-container:5432/$DATABASE_NAME?serverVersion=13&charset=utf8\"" >> ./docker/.env

    echo '' >> ./docker/docker-compose.yml
    echo '' >> ./docker/docker-compose.yml

    echo "  db:
    container_name: database-container
    image: postgres:12
    restart: always
    environment:
        POSTGRES_PASSWORD: $DATABASE_PASSWORD
        POSTGRES_DB: $DATABASE_NAME
    ports:
        - 5432:5432
    volumes:
        - ./data/postgres:/var/lib/postgresql/data" >> ./docker/docker-compose.yml
fi

if [ $DATABASE = 'mysql' ]; then
    echo "DATABASE_URL=\"mysql://db_user:db_password@127.0.0.1:3306/db_name?serverVersion=5.7\"" >> ./docker/.env
fi

if [ $SERVER = 'nginx' ]; then
    echo '' >> ./docker/docker-compose.yml
    echo '' >> ./docker/docker-compose.yml

    echo "  nginx:
    container_name: server-container
    build:
      context: ./nginx
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

read -p 'What is your Git email: ' GIT_EMAIL
read -p 'What is your Git name: ' GIT_NAME

echo "#!/bin/sh

git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"
symfony new /var/www --version=\"$SYMFONY_VERSION\" --webapp" > ./docker/php-fpm/create-symfony-project.sh

echo "SYMFONY_VERSION="$SYMFONY_VERSION >> ./docker/.env
echo "PHP_VERSION="$PHP_VERSION >> ./docker/.env
echo "DATABASE="$DATABASE >> ./docker/.env
echo "SERVER="$SERVER >> ./docker/.env

cd docker
docker compose up --build