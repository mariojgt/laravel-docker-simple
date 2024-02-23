.PHONY: start stop build composer list create-network remove-network

COMPOSE =sudo docker-compose
DOCKER = sudo docker
# Load .env file
DOCKER_PREFIX:= $(shell grep -E '^DOCKER_PREFIX' .env | cut -d '=' -f 2)
NETWORK_NAME:= $(shell grep -E '^NETWORK_NAME' .env | cut -d '=' -f 2)
CONTAINER_NAME:= $(shell grep -E '^CONTAINER_NAME' .env | cut -d '=' -f 2)
PHPMYADMIN_PORT:= $(shell grep -E '^PHPMYADMIN_PORT' .env | cut -d '=' -f 2)
MYAPP_PORT:= $(shell grep -E '^MYAPP_PORT' .env | cut -d '=' -f 2)
MYSQL_PORT:= $(shell grep -E '^MYSQL_PORT' .env | cut -d '=' -f 2)
REDIS_PORT:= $(shell grep -E '^REDIS_PORT' .env | cut -d '=' -f 2)

network:
	@$(DOCKER) network create $(NETWORK_NAME)

remove-network:
	@$(DOCKER) network rm $(NETWORK_NAME)

list-network:
	@$(DOCKER) network ls

start:
	@$(COMPOSE) up -d

stop:
	@$(COMPOSE) down

build:
	@$(COMPOSE) build

list:
	@$(COMPOSE) ps -a

link:
	@echo "Creating IP address and port list for services with '$(DOCKER_PREFIX)_' prefix..."
	@SERVER_IP=$$(hostname -I | cut -d' ' -f1); \
	$(DOCKER) ps --format "{{.Names}}\t{{.Ports}}" | \
	awk -v serverip=$$SERVER_IP '/$(DOCKER_PREFIX)/ {split($$2, port, "[:>]"); print serverip":"port[2]}'

exe:
	@$(DOCKER) exec -it ${DOCKER_PREFIX}_${CONTAINER_NAME}-app /bin/bash

composer:
	@$(DOCKER) exec -it ${DOCKER_PREFIX}_${CONTAINER_NAME}-app /bin/bash -c 'composer install && chmod -R 777 storage bootstrap/cache'

npm:
	@$(DOCKER) exec -it ${DOCKER_PREFIX}_${CONTAINER_NAME}-app /bin/bash -c 'npm install && npm run dev'

npm-upgrade:
	@$(DOCKER) exec -it ${DOCKER_PREFIX}_${CONTAINER_NAME}-app /bin/bash -c 'npm upgrade'

npm-update:
	@$(DOCKER) exec -it ${DOCKER_PREFIX}_${CONTAINER_NAME}-app /bin/bash -c 'npm update'