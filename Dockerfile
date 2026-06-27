FROM alpine:3.22.0

RUN apk add --no-cache \
    xmlstarlet=1.6.1-r2

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
