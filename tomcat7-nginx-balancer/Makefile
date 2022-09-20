default: build

COMPOSE_FILE = docker-compose.yml

## docker-compose shortcuts
build:
	@docker-compose --compatibility -f $(COMPOSE_FILE) build

run:
	@docker-compose --compatibility -f $(COMPOSE_FILE) up

start:
	@docker-compose --compatibility -f $(COMPOSE_FILE) up -d

stop:
	@docker-compose --compatibility -f $(COMPOSE_FILE) stop

logs:
	@docker-compose --compatibility -f $(COMPOSE_FILE) logs -f

ps:
	@docker-compose --compatibility -f $(COMPOSE_FILE) ps

shell:
	@docker-compose --compatibility -f $(COMPOSE_FILE) exec srv-tomcat sh
