default: build

COMPOSE_FILE = docker-compose.yml

## docker-compose shortcuts
build:
	@docker-compose -f $(COMPOSE_FILE) build

run:
	@docker-compose -f $(COMPOSE_FILE) up

start:
	@docker-compose -f $(COMPOSE_FILE) up -d

stop:
	@docker-compose -f $(COMPOSE_FILE) stop

logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

ps:
	@docker-compose -f $(COMPOSE_FILE) ps

shell:
	@docker-compose -f $(COMPOSE_FILE) exec zookeeper sh

