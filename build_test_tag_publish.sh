#!/usr/bin/env bash
set -Eeu

export SH_DIR="$( cd "$( dirname "${0}" )/sh" && pwd )"
source ${SH_DIR}/env_vars.sh
export $(env_vars)

${SH_DIR}/build_images.sh
${SH_DIR}/run_container.sh
${SH_DIR}/open_browser.sh
