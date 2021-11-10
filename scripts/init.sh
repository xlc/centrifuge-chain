#!/usr/bin/env bash

set -e

cmd=$1
parachain="${PARA_CHAIN_SPEC:-devel-local}"
para_id="${PARA_ID:-2000}"

case $cmd in
install-toolchain)
  ./scripts/install_toolchain.sh
  ;;

start-relay-chain)
  echo "Starting local relay chain with Alice and Bob..."
  docker-compose -f ./docker-compose-local-relay.yml up -d node_alice node_bob
  ;;

stop-relay-chain)
  echo "Stopping relay chain..."
  docker-compose -f ./docker-compose-local-relay.yml rm -fsv node_alice node_bob
  ;;

start-parachain)
  echo "Starting para chain..."
  docker-compose -f ./docker-compose-local-relay.yml up -d para_alice
  ;;

stop-parachain)
  echo "Stopping para chain..."
  docker-compose -f ./docker-compose-local-relay.yml rm -fsv para_alice
  ;;

onboard-parachain)
  genesis=$(docker run centrifugeio/centrifuge-chain:uniques-latest centrifuge-chain export-genesis-state --chain="${parachain}" --parachain-id="${para_id}")
  wasm=$(docker run centrifugeio/centrifuge-chain:uniques-latest centrifuge-chain export-genesis-wasm --chain="${parachain}")
  echo "Genesis state:" "$genesis"
  echo "${wasm}" > ./centrifuge_chain.wasm
  echo "WASM:" "./centrifuge_chain.wasm"
  ;;

benchmark)
  ./scripts/run_benchmark.sh "${parachain}" "$2" "$3"
esac
