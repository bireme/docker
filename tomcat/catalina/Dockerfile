FROM tomcat:8-alpine

COPY tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
COPY app.war /usr/local/tomcat/webapps/
COPY context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml

EXPOSE 8080

CMD ["catalina.sh", "run"]
