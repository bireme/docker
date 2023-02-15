FROM docker.io/bitnami/solr:9.1.1

# copy decs lucene index
COPY ./resources /opt/bitnami/solr/server/resources
# copy custom iahx analyzers to solr webapp lib folder
COPY ./lib /opt/bitnami/solr/server/solr-webapp/webapp/WEB-INF/lib
