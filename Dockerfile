FROM alpine:3.22.0

RUN apk add --no-cache \
    xmlstarlet

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
