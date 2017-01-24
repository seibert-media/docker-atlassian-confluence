##############################################################################
# Dockerfile to build Atlassian Confluence container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ARG VERSION

ENV CONFLUENCE_INST /opt/confluence
ENV CONFLUENCE_HOME /var/opt/confluence
ENV SYSTEM_USER confluence
ENV SYSTEM_GROUP confluence
ENV SYSTEM_HOME /home/confluence

RUN set -x \
  && apk add su-exec tar xmlstarlet wget ca-certificates --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p ${CONFLUENCE_INST} \
  && mkdir -p ${CONFLUENCE_HOME}

RUN set -x \
  && mkdir -p ${SYSTEM_HOME} \
  && addgroup -S ${SYSTEM_GROUP} \
  && adduser -S -D -G ${SYSTEM_GROUP} -h ${SYSTEM_HOME} -s /bin/sh ${SYSTEM_USER} \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${SYSTEM_HOME}

RUN set -x \
  && wget -nv -O /tmp/atlassian-confluence-${VERSION}.tar.gz https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${VERSION}.tar.gz \
  && tar xfz /tmp/atlassian-confluence-${VERSION}.tar.gz --strip-components=1 -C ${CONFLUENCE_INST} \
  && rm /tmp/atlassian-confluence-${VERSION}.tar.gz \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${CONFLUENCE_INST}

RUN set -x \
  && touch -d "@0" "${CONFLUENCE_INST}/conf/server.xml" \
  && touch -d "@0" "${CONFLUENCE_INST}/bin/setenv.sh" \
  && touch -d "@0" "${CONFLUENCE_INST}/confluence/WEB-INF/classes/confluence-init.properties"

ADD files/service /usr/local/bin/service
ADD files/entrypoint /usr/local/bin/entrypoint

EXPOSE 8009 8090 8091

VOLUME ${CONFLUENCE_HOME}

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["/usr/local/bin/service"]
