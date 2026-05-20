default: build

# Use 'docker compose' if available (Docker 20.10+), otherwise fall back to 'docker-compose'
DOCKER_COMPOSE := $(shell command -v docker-compose 2>/dev/null && echo docker-compose || echo docker) compose

## docker-compose shortcuts
build:
	@$(DOCKER_COMPOSE) build

run:
	@$(DOCKER_COMPOSE) up

up:
	@$(DOCKER_COMPOSE) up -d

logs:
	@$(DOCKER_COMPOSE) logs -f

stop:
	@$(DOCKER_COMPOSE) stop

ps:
	@$(DOCKER_COMPOSE) ps

shell:
	@$(DOCKER_COMPOSE) exec solr sh

index_example:
	@$(DOCKER_COMPOSE) exec solr post -c gettingstarted example/exampledocs/manufacturers.xml