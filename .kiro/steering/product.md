# dcrdata – Product Overview

dcrdata is an open-source block explorer for the [Decred](https://www.decred.org/) cryptocurrency. It collects, stores, and presents blockchain data via a web UI and two HTTP APIs.

## Core capabilities

- Block explorer web interface (blocks, transactions, addresses, tickets, treasury, governance)
- dcrdata REST JSON API (`/api` prefix)
- Insight-compatible REST API (`/insight/api` prefix)
- Websocket pub-sub server for real-time blockchain events
- Mempool monitoring and reporting
- Exchange rate bot with gRPC server
- On-chain and off-chain governance data (Politeia proposals, consensus agendas)

## Runtime dependencies

- `dcrd` node running with `--txindex`, synced to the network
- PostgreSQL 11+ as the primary data store
- Reverse proxy (e.g. nginx) recommended for production

## Default endpoint

`http://127.0.0.1:7777/`

## License

ISC
