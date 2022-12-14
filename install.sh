#!/bin/bash

curl -LkSs https://api.github.com/repos/CaioDGallo/docker-symfony/tarball -o main.tar.gz
tar -zxvf main.tar.gz
sudo cp -r CaioDGallo-docker-symfon* /etc/docker-symfony
sudo chown -R $(whoami) /etc/docker-symfony
sudo cp /etc/docker-symfony/docker-symfony.sh /usr/bin/docker-symfony 
sudo chmod 755 /usr/bin/docker-symfony
rm -rf CaioDGallo-docker-symfon*
rm -rf main.tar.gz