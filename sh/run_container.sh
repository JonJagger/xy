#!/usr/bin/env bash
set -Eeu

run_container()
{
  docker-compose \
    --file "${SH_DIR}/../docker-compose.yml" \
    up \
    -d
}

run_container
