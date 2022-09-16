#!/bin/sh

git config --global user.email "dsad@fwef.ggre"
git config --global user.name "gregre"
symfony new /var/www --version="6.1.*" --webapp
composer i -o;
wait-for-it db:5432 -- bin/console doctrine:migrations:migrate
cp /home/.htaccess /var/www/.htaccess
