##############################################################################
# Dockerfile to build Atlassian Confluence container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ARG VERSION
ARG MYSQL_JDBC_VERSION

ENV CONFLUENCE_INST /opt/atlassian/confluence
ENV CONFLUENCE_HOME /var/opt/atlassian/application-data/confluence
ENV SYSTEM_USER confluence
ENV SYSTEM_GROUP confluence
ENV SYSTEM_HOME /home/confluence

RUN set -x \
  && apk add git tar xmlstarlet wget ca-certificates --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p $CONFLUENCE_INST \
  && mkdir -p $CONFLUENCE_HOME

RUN set -x \
  && mkdir -p /home/$SYSTEM_USER \
  && addgroup -S $SYSTEM_GROUP \
  && adduser -S -D -G $SYSTEM_GROUP -h $SYSTEM_GROUP -s /bin/sh $SYSTEM_USER \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP /home/$SYSTEM_USER

RUN set -x \
  && wget -O /tmp/atlassian-confluence-$VERSION.tar.gz https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-$VERSION.tar.gz \
  && tar xfz /tmp/atlassian-confluence-$VERSION.tar.gz --strip-components=1 -C $CONFLUENCE_INST \
  && rm /tmp/atlassian-confluence-$VERSION.tar.gz

RUN set -x \
  && wget -O /tmp/mysql-connector-java-$MYSQL_JDBC_VERSION.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_JDBC_VERSION.tar.gz \
  && tar xfz /tmp/mysql-connector-java-$MYSQL_JDBC_VERSION.tar.gz mysql-connector-java-$MYSQL_JDBC_VERSION/mysql-connector-java-$MYSQL_JDBC_VERSION-bin.jar -C $CONFLUENCE_INST/confluence/WEB-INF/lib/ \
  && rm /tmp/mysql-connector-java-$MYSQL_JDBC_VERSION.tar.gz

RUN set -x \
  && touch -d "@0" "$CONFLUENCE_INST/conf/server.xml" \
  && touch -d "@0" "$CONFLUENCE_INST/bin/setenv.sh" \
  && touch -d "@0" "$CONFLUENCE_INST/confluence/WEB-INF/classes/confluence-init.properties"

ADD files/service /usr/local/bin/service
ADD files/entrypoint /usr/local/bin/entrypoint

RUN set -x \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP /usr/local/bin/service \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP /usr/local/bin/entrypoint \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP $CONFLUENCE_INST \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP $CONFLUENCE_HOME

EXPOSE 8090 8091

USER $SYSTEM_USER

VOLUME $CONFLUENCE_HOME

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["/usr/local/bin/service"]
