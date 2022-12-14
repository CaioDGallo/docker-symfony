# Docker-Symfony

This project is a simple bash script to setup a docker environment, with docker compose, for a Symfony project.

## Tech Stack Available

- Symfony Versions: `v6.1.*`, `v6.0.*` and `v5.4.*`
- PHP Versions: `8.1`, `8.0.2` and `7.2.5`
- Databases: `PostgreSQL` or `MySQL`
- Webserver: `Nginx` or `Apache`
- Supports localhost (port 80) and custom vhosts for both webservers

## Download

- Ubuntu and Debian based distros 
> Note: It does need `root` permission (sudo) for some file copying and permission changes
```sh
bash <(curl -s https://raw.githubusercontent.com/CaioDGallo/docker-symfony/main/install.sh)
```

## Setup

Docker-Symfony requires [Docker](https://docs.docker.com/engine/install/) to run.

### Ubuntu/WSL2

- Run the `docker-symfony PROJECT_PATH` command and follow the instructions.
- If you choose to use custom vhosts, don't forget to add them to your hosts file: 
    - `/etc/hosts` for Ubuntu
    - `C:\Windows\System32\Drivers\etc\hosts` on the Windows host machine for WSL2 installations.

![VHOSTS](docs/vhosts.png?raw=true "vhosts instruction")

## Uninstall

- To remove Docker-Symfony from your system run `docker-symfony --uninstall`
> Note: It needs `root` permission
