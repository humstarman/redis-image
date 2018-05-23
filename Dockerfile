FROM lowyard/busybox-curl:latest as build
ENV redis_ver 4.0.9
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://download.redis.io/releases/redis-${redis_ver}.tar.gz | \
      tar -zx

FROM ubuntu:16.04
ENV redis_ver 4.0.9
RUN mkdir -p /opt
WORKDIR /opt
COPY --from=build /opt/redis-${redis_ver} /opt/redis-${redis_ver}/
RUN ln -s redis-${redis_ver} redis && \
    echo Redis ${redis_ver} installed in /opt
RUN apt-get update && \
    apt-get install -y gcc make tcl ruby gem
RUN gem install redis
WORKDIR /opt/redis
RUN make MALLOC=libc
RUN make test 
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /usr/share/man /usr/share/doc
