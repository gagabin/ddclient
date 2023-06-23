FROM docker.io/library/alpine:latest AS ddclient
RUN apk add curl jq autoconf automake make
RUN curl -Ssf --header "X-GitHub-Api-Version:2022-11-28" \
    https://api.github.com/repos/ddclient/ddclient/releases/latest \
    | jq -r '.tarball_url' \
    | xargs wget -O ddclient.tar.gz
RUN mkdir ddclient
RUN tar xf ddclient.tar.gz -C ddclient --strip-components=1
WORKDIR ddclient
RUN ls
RUN ./autogen
RUN ./configure --prefix=/usr/local --sysconfdir=/container/config
RUN make install

FROM docker.io/library/alpine:latest
RUN apk upgrade --no-cache
RUN apk add --no-cache perl perl-io-socket-ssl
COPY --from=ddclient /usr/local /usr/local
ENTRYPOINT ["ddclient", "-foreground"]
CMD ["-ssl"]
