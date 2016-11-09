##############################################################################
# Dockerfile to build Atlassian Confluence container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

RUN set -x \
  && echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk update \
  && apk add git tar xmlstarlet@testing

RUN set -x \
  && mkdir -p /opt/atlassian/confluence \
  && mkdir -p /var/opt/atlassian/application-data/confluence

ADD files/entrypoint /usr/local/bin/entrypoint

RUN set -x \
  && chown -R daemon:daemon /usr/local/bin/entrypoint \
  && chown -R daemon:daemon /opt/atlassian/confluence \
  && chown -R daemon:daemon /var/opt/atlassian/application-data/confluence

USER daemon

ENTRYPOINT  ["/usr/local/bin/entrypoint"]
