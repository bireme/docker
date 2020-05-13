COMPOSE_FILE = docker-compose.yml

## docker-compose shortcuts
build:
	@docker-compose -f $(COMPOSE_FILE) build

up:
	@docker-compose -f $(COMPOSE_FILE) up -d

logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f 

stop:
	@docker-compose -f $(COMPOSE_FILE) stop

ps:
	@docker-compose -f $(COMPOSE_FILE) ps

shell:
	@docker-compose -f $(COMPOSE_FILE) exec nginx-proxy sh

create_network:
	@docker network create nginx-proxy
