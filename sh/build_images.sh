#!/usr/bin/env bash
set -Eeu

#- - - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
  docker-compose \
    --file "${SH_DIR}/../docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA="$(git_commit_sha)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${SH_DIR}/.." && git rev-parse HEAD)
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_equal()
{
  local -r name="${1}"
  local -r expected="${2}"
  local -r actual="${3}"
  echo "expected: ${name}='${expected}'"
  echo "  actual: ${name}='${actual}'"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR: unexpected ${name} inside image"
    exit 42
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - -
source ${SH_DIR}/env_vars.sh
export $(env_vars)
source ${SH_DIR}/image_sha.sh
build_images
assert_equal SHA "$(git_commit_sha)" "$(image_sha)"
