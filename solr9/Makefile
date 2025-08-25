default: build

## docker compose shortcuts
build:
	@docker compose build --no-cache

run:
	@docker compose up

start:
	@docker compose up -d

stop:
	@docker compose stop

logs:
	@docker compose logs -f

ps:
	@docker compose ps

shell:
	@docker -compose exec solr sh

index_example:
	@docker-compose exec solr post -c gettingstarted example/exampledocs/manufacturers.xml