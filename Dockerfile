FROM alpine:3.6

WORKDIR /usr
RUN apk --no-cache add gcc \
        g++ \
        make \
        perl \
        perl-dev \
        curl \
    && curl -sL --compressed https://git.io/cpm > cpm && chmod +x cpm \
    && ./cpm install Plack \
    && ./cpm install Dancer Plack::Middleware::ReverseProxy \
        Net::DNS::Resolver JSON \
        YAML \
        List::MoreUtils \
        Net::CIDR::Lite \
        Plack::Handler::Twiggy \
    && mkdir -p /app/logs

ENV PERL5LIB=/usr/local/lib/perl5
ENV PATH=/usr/local/bin:$PATH

WORKDIR /app

COPY bin/ bin/
COPY lib/ lib/
COPY t/ lib/
COPY public/ public/
COPY run run

EXPOSE 5001

ENTRYPOINT ["./run"]
