# docker-bitcoin-abc

Bitcoin uses peer-to-peer technology to operate with no central authority or
banks; managing transactions and the issuing of bitcoin is carried out
collectively by the network. Bitcoin is open-source; its design is public,
nobody owns or controls Bitcoin and everyone can take part. Through many of its
unique properties, Bitcoin allows exciting uses that could not be covered by any
previous payment system.

This Docker image focuses on providing a very thin image to run and interact
with a Bitcoin ABC node. It is built on Alpine Linux and includes the `bitcoin`,
`bitcoin-cli`, and `bitcoin-tx` binaries. This allows the node to be
lightweight, with minimal dependencies or extra packages.

This image is based on [amacneil/docker-bitcoin](https://github.com/amacneil/docker-bitcoin).


### Usage

To start a bitcoind instance running the latest version (`0.12.2`):

```
$ docker run --name bitcoin-node krobertson/bitcoin-abc
```

To run a bitcoin container in the background, pass the `-d` option to `docker
run`:

```
$ docker run -d --name bitcoin-node krobertson/bitcoin-abc
```

Once you have a bitcoin service running in the background, you can show running
containers:

```
$ docker ps
```

Or view the logs of a service:

```
$ docker logs -f some-bitcoin
```

To stop and restart a running container:

```
$ docker stop bitcoin-node
$ docker start bitcoin-node
```


### Data Volumes

By default, Docker will create ephemeral containers. That is, the blockchain
data will not be persisted if you create a new bitcoin container.

To create a simple `busybox` data volume and link it to a bitcoin service:

```
$ docker create -v /data --name btcdata busybox /bin/true
$ docker run --volumes-from btcdata krobertson/bitcoin-abc
```


### Configuring Bitcoin

The easiest method to configure the bitcoin server is to pass arguments to the
`bitcoind` command. For example, to run bitcoin on the testnet:

```
$ docker run --name bitcoin-testnet krobertson/bitcoin-abc bitcoind -testnet
```
