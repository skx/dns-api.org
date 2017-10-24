FROM alpine

WORKDIR /usr
RUN apk update && apk add gcc g++ make perl perl-dev curl
RUN curl -sL --compressed https://git.io/cpm > cpm && chmod +x cpm 
RUN ./cpm install Plack
RUN ./cpm install Dancer Plack::Middleware::ReverseProxy Net::DNS::Resolver JSON \
    YAML List::MoreUtils Net::CIDR::Lite Plack::Handler::Twiggy

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
