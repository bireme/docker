default: build

# Use 'docker compose' if available (Docker 20.10+), otherwise fall back to 'docker-compose'
DOCKER_COMPOSE := $(shell command -v docker-compose 2>/dev/null && echo docker-compose || echo docker) compose

## docker-compose shortcuts
update:
	@$(DOCKER_COMPOSE) down
	@$(DOCKER_COMPOSE) pull

run:
	@$(DOCKER_COMPOSE) up

start:
	@$(DOCKER_COMPOSE) up -d

stop:
	@$(DOCKER_COMPOSE) stop

logs:
	@$(DOCKER_COMPOSE) logs -f

ps:
	@$(DOCKER_COMPOSE) ps

shell:
	@$(DOCKER_COMPOSE) exec uptime sh
