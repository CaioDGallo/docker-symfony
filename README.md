## To-Do

- Make docker-symfony.sh create the project on the specified folder/path and copy the docker folder there.
- Add SSL to nginx
- sudo rm -rf /etc/docker-symfony && sudo rm -rf /usr/bin/docker-symfony && sudo cp -r /home/caiogallo/Documents/caio_projects/docker-symfony /etc/docker-symfony && sudo cp /home/caiogallo/Documents/caio_projects/docker-symfony/docker-symfony.sh /usr/bin/docker-symfony && sudo chmod 755 /usr/bin/docker-symfony && sudo chown -R $(whoami) /etc/docker-symfony


# Docker-Symfony

Write about it

## Download

## Setup

Docker-Symfony requires [Docker](https://docs.docker.com/engine/install/) to run.

### Ubuntu

- Run the `docker-symfony` command and follow the instructions.
- If you choose to use custom vhosts, don't forget to add them to your `/etc/hosts` file.

![VHOSTS](docs/vhosts.png?raw=true "vhosts instruction")