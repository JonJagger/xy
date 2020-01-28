#!/bin/bash -Ee

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )"
source ${SH_DIR}/ip_address.sh
readonly IP_ADDRESS=$(ip_address)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
port() { printf 80; }
display_name() { printf 'Java Countdown, Round 1'; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_json()
{
  local -r type=${1}
  local -r route=${2}
  curl  \
    --data-urlencode "display_name=$(display_name)" \
    --fail \
    --header 'Accept: application/json' \
    --silent \
    -X ${type} \
    "http://${IP_ADDRESS}:$(port)/${route}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_http_302()
{
  local -r type=${1}
  local -r route=${2}
  local -r log=/tmp/custom.log
  curl  \
    --data-urlencode "display_name=$(display_name)" \
    --fail \
    --header 'Accept: text/html' \
    --silent \
    --verbose \
    -X ${type} \
    "http://${IP_ADDRESS}:$(port)/${route}" \
     > ${log} 2>&1
  grep --quiet 302 ${log}                   # eg HTTP/1.1 302 Moved Temporarily
  local -r location=$(grep Location ${log}) # eg Location: http://192.168.99.100/kata/edit/mzCS1h
  printf "kata${location#*kata}"            # eg /kata/edit/mzCS1h
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_api()
{
  local -r controller=custom
  printf "API /${controller}/...\n"
  printf "\t200 GET .../alive? => $(curl_json GET ${controller}/alive?)\n"
  printf "\t200 GET .../ready? => $(curl_json GET ${controller}/ready?)\n"
  printf "\t200 GET .../sha    => $(curl_json GET ${controller}/sha)\n"
  printf '\n'
  printf "\t302 POST HTTP .../create_kata  => $(curl_http_302 POST ${controller}/create_kata)\n"
  printf "\t302 POST HTTP .../create_group => $(curl_http_302 POST ${controller}/create_group)\n"
  printf '\n'
  printf "\t200 POST JSON .../create_kata  => $(curl_json POST ${controller}/create_kata)\n"
  printf "\t200 POST JSON .../create_group => $(curl_json POST ${controller}/create_group)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_deprecated_api()
{
  local -r controller=setup_custom_start_point
  printf "Deprecated API (nginx redirect) /${controller}/...\n"
  printf "\t302 POST HTTP .../save_individual => $(curl_http_302 POST ${controller}/save_individual)\n"
  printf "\t302 POST HTTP .../save_group      => $(curl_http_302 POST ${controller}/save_group)\n"
  printf '\n'
  printf "\t200 POST JSON .../save_individual_json => $(curl_json POST ${controller}/save_individual_json)\n"
  printf "\t200 POST JSON .../save_group_json      => $(curl_json POST ${controller}/save_group_json)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
source ${SH_DIR}/versioner_env_vars.sh
export $(versioner_env_vars)

${SH_DIR}/build_images.sh
${SH_DIR}/containers_up.sh
printf '\n'
demo_api
printf '\n'
demo_deprecated_api
printf '\n'
if [ "${1}" == '--http' ]; then
  open http://${IP_ADDRESS}:$(port)/custom/index?for=group
else
  ${SH_DIR}/containers_down.sh
fi
