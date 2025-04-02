default: run

core?=test
container?=solr9-srv1
shards?=3
replication?=2

## docker-compose shortcuts
run:
	@docker-compose up

start:
	@docker-compose up -d

logs:
	@docker-compose logs -f

stop:
	@docker-compose stop

rm:
	@docker-compose rm -f

down:
	@docker-compose down

ps:
	@docker-compose ps

sh:
	@docker-compose exec --user bireme solr bash

sh_root:
	@docker-compose exec --user root solr bash

update_configsets:
	docker  cp ./conf/configsets/ $(container):/bitnami/solr/server/solr/

update_core_config:
	docker cp ./conf/configsets/$(core)/conf/ $(container):/bitnami/solr/server/solr/$(core)/

zk_upconfig:
	docker-compose exec -T solr /opt/bitnami/solr/bin/solr zk upconfig -n $(core) -d /bitnami/solr/server/solr/configsets/$(core)/

create_core:
	docker-compose exec -T solr /opt/bitnami/solr/bin/solr create_core -c $(core) -d $(core)

create_collection_cloud:
	docker-compose exec -T solr /opt/bitnami/solr/bin/solr create_collection -c $(core) -d $(core) -shards $(shards) -replicationFactor $(replication)

