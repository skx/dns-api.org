FROM ytnobody/alpine-perl

WORKDIR /usr

RUN cpm install Dancer Plack::Middleware::ReverseProxy Net::DNS::Resolver JSON \
    YAML List::MoreUtils Net::CIDR::Lite Plack::Handler::Twiggy

# RUN apk add --update nginx

ENV PERL5LIB=/usr/local/lib/perl5
ENV PATH=/usr/local/bin:$PATH

RUN mkdir -p /app/logs

WORKDIR /app

COPY bin/ bin/
COPY lib/ lib/
COPY t/ lib/
COPY public/ public/
COPY run run

EXPOSE 5001

ENTRYPOINT ["./run"]
