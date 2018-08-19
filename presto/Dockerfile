# From https://github.com/voldern/docker-presto/blob/master/Dockerfile
FROM java:8-jdk

RUN apt-get update && apt-get install -y python

ENV DEBIAN_FRONTEND noninteractive

COPY archives/presto-server-0.208.tar.gz /tmp/presto.tar.gz

RUN mkdir /opt/presto
RUN tar -zxvf /tmp/presto.tar.gz -C /opt/presto --strip-components=1
RUN rm /tmp/presto.tar.gz

COPY config/ /opt/presto/etc/

EXPOSE 8080

CMD ["/opt/presto/bin/launcher", "run"]