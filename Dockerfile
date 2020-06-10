FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

ENV PG_MAJOR 11
ENV PG_VERSION 11.8-1.pgdg80+1

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update -y -q && \
  apt-get install -y wget postgresql-common postgresql-client-11 python-pip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN pip install awscli

ADD backup.sh /backup.sh
RUN chmod 0755 /backup.sh

ENTRYPOINT ["/backup.sh"]
