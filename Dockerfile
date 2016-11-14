##############################################################################
# Dockerfile to build Atlassian Confluence container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ENV VERSION 0.0.0

RUN set -x \
  && apk add git tar xmlstarlet --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p /opt/atlassian/confluence \
  && mkdir -p /var/opt/atlassian/application-data/confluence

ADD https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-$VERSION.tar.gz /tmp

RUN set -x \
  && tar xvfz /tmp/atlassian-confluence-$VERSION.tar.gz --strip-components=1 -C /opt/atlassian/confluence \
  && rm /tmp/atlassian-confluence-$VERSION.tar.gz

RUN set -x \
  && sed --in-place 's/# confluence.home=c:\/confluence\/data/confluence.home=\/var\/opt\/atlassian\/application-data\/confluence/' /opt/atlassian/confluence/confluence/WEB-INF/classes/confluence-init.properties

RUN set -x \
  && touch -d "@0" "/opt/atlassian/confluence/conf/server.xml" \
  && touch -d "@0" "/opt/atlassian/confluence/bin/setenv.sh"

ADD files/entrypoint /usr/local/bin/entrypoint
ADD files/_.codeyard.com.crt /tmp/_codeyard.com.crt

RUN set -x \
  && /opt/jdk/bin/keytool -import -trustcacerts -noprompt -keystore /opt/jdk/jre/lib/security/cacerts -storepass changeit -alias CODEYARD -file /tmp/_codeyard.com.crt

RUN set -x \
  && chown -R daemon:daemon /usr/local/bin/entrypoint \
  && chown -R daemon:daemon /opt/atlassian/confluence \
  && chown -R daemon:daemon /var/opt/atlassian/application-data/confluence

EXPOSE 8090
EXPOSE 8091

USER daemon

ENTRYPOINT  ["/usr/local/bin/entrypoint"]
