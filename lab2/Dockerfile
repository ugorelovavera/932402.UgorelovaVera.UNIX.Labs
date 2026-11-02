FROM alpine:latest
RUN apk add --no-cache util-linux
RUN mkdir -p /shared
COPY worker.sh /worker.sh
RUN chmod +x /worker.sh
ENTRYPOINT ["/worker.sh"]
