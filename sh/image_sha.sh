#!/usr/bin/env bash
set -Eeu

source "${SH_DIR}/image_name.sh"

image_sha()
{
  docker run --rm $(image_name) sh -c 'echo ${SHA}'
}
