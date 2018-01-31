FROM alpine:3.6

ENV GLIBC_VERSION=2.26-r0 \
    BITCOIN_VERSION=0.16.2 \
    BITCOIN_URL=https://download.bitcoinabc.org/0.16.2/linux/bitcoin-abc-0.16.2-x86_64-linux-gnu.tar.gz \
    BITCOIN_SHA256=5eeadea9c23069e08d18e0743f4a86a9774db7574197440c6d795fad5cad2084 \
    BITCOIN_DATA=/data

RUN set -ex \
    # Install necessary packages
    && apk --no-cache add ca-certificates wget gnupg \

    # Install and validate gosu -- GPG key: Tianon Gravi <tianon@tianon.xyz>
    && gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && wget -qO /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" \
    && wget -qO /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \

    # Install glibc binaries
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
    && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
    && apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk \

    # Install Bitcoin binaries
    && BITCOIN_DIST=$(basename $BITCOIN_URL) \
    && wget -O $BITCOIN_DIST $BITCOIN_URL \
    && echo "$BITCOIN_SHA256  $BITCOIN_DIST" | sha256sum -c - \
    && mkdir bitcoin-bin \
    && tar -xzvf $BITCOIN_DIST -C bitcoin-bin --strip-components=2 --exclude=*-qt \
    && mv bitcoin-bin/bitcoind bitcoin-bin/bitcoin-cli bitcoin-bin/bitcoin-tx /usr/local/bin/ \
    && rm -r bitcoin* \

    # Cleanup
    && apk del wget gnupg \

    # Create the user and group
    && addgroup -S bitcoin && adduser -S -G bitcoin bitcoin \

    # Create the data volume
    && mkdir $BITCOIN_DATA \
    && chown bitcoin:bitcoin $BITCOIN_DATA \
    && ln -s $BITCOIN_DATA /home/bitcoin/.bitcoin

VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["bitcoind"]
