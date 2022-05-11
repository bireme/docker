FROM solr:8.11.1

# copy decs lucene index
COPY ./resources /opt/solr/server/resources
# copy custom iahx analyzers to solr webapp lib folder
COPY ./lib /opt/solr/server/solr-webapp/webapp/WEB-INF/lib
