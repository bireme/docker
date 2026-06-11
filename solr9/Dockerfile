FROM solr:9

# DeCS Lucene index consumed by the iahx custom analyzers
# (loaded from the classpath under server/resources/decs)
COPY --chown=solr:solr ./resources/decs /opt/solr/server/resources/decs

# Bundle the iahx custom analyzer into Solr's webapp lib
COPY --chown=solr:solr ./lib/iahx-analyzer.jar \
     /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/
