##############################################################################
# Dockerfile to build Atlassian Confluence container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ARG VERSION

ENV CONFLUENCE_INST /opt/atlassian/confluence
ENV CONFLUENCE_HOME /var/opt/atlassian/application-data/confluence

RUN set -x \
  && apk add git tar xmlstarlet --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p $CONFLUENCE_INST \
  && mkdir -p $CONFLUENCE_HOME

ADD https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-$VERSION.tar.gz /tmp

RUN set -x \
  && tar xvfz /tmp/atlassian-confluence-$VERSION.tar.gz --strip-components=1 -C $CONFLUENCE_INST \
  && rm /tmp/atlassian-confluence-$VERSION.tar.gz

RUN set -x \
  && touch -d "@0" "$CONFLUENCE_INST/conf/server.xml" \
  && touch -d "@0" "$CONFLUENCE_INST/bin/setenv.sh" \
  && touch -d "@0" "$CONFLUENCE_INST/confluence/WEB-INF/classes/confluence-init.properties"

ADD files/entrypoint /usr/local/bin/entrypoint

RUN set -x \
  && chown -R daemon:daemon /usr/local/bin/entrypoint \
  && chown -R daemon:daemon $CONFLUENCE_INST \
  && chown -R daemon:daemon $CONFLUENCE_HOME

EXPOSE 8090
EXPOSE 8091

USER daemon

ENTRYPOINT  ["/usr/local/bin/entrypoint"]
