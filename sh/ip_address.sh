#!/usr/bin/env bash
set -Eeu

ip_address()
{
  if [ ! -z "${DOCKER_MACHINE_NAME:-}" ]; then
    docker-machine ip "${DOCKER_MACHINE_NAME}"
  else
    echo localhost
  fi
}
