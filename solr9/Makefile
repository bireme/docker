default: build

include .env
export

## image build
build:
	@docker build --no-cache -t $(BIREME_SOLR_IMAGE_NAME) .

## docker compose shortcuts (deploy)
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
	@docker compose exec solr sh

index_example:
	@docker compose exec solr post -c gettingstarted example/exampledocs/manufacturers.xml
