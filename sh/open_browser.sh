#!/usr/bin/env bash
set -Eeu

source "${SH_DIR}/ip_address.sh"

sleep 1
open "http://$(ip_address):${XY_PORT}/xy"
