#!/usr/bin/env sh
# shellcheck disable=SC3043 #https://github.com/koalaman/shellcheck/wiki/SC3043#exceptions

# Pi-hole: A black hole for Internet advertisements
# (c) 2017 Pi-hole, LLC (https://pi-hole.net)
# Network-wide ad blocking via your own hardware.
#
# Script to hold utility functions for use in other scripts
#
# This file is copyright under the latest version of the EUPL.
# Please see LICENSE file for your rights under this license.

# Basic Housekeeping rules
#  - Functions must be self contained
#  - Functions should be grouped with other similar functions
#  - Functions must be documented
#  - New functions must have a test added for them in test/test_any_utils.py

#######################
# Takes Three arguments: file, key, and value.
#
# Checks the target file for the existence of the key
#   - If it exists, it changes the value
#   - If it does not exist, it adds the value
#
# Example usage:
# addOrEditKeyValPair "/etc/pihole/setupVars.conf" "BLOCKING_ENABLED" "true"
#######################
addOrEditKeyValPair() {
  local file="${1}"
  local key="${2}"
  local value="${3}"

  if grep -q "^${key}=" "${file}"; then
      # Key already exists in file, modify the value
      sed -i "/^${key}=/c\\${key}=${value}" "${file}"
  else
    # Key does not already exist, add it and it's value
    echo "${key}=${value}" >> "${file}"
  fi
}

#######################
# Takes two arguments: file, and key.
# Adds a key to target file
#
# Example usage:
# addKey "/etc/dnsmasq.d/01-pihole.conf" "log-queries"
#######################
addKey(){
  local file="${1}"
  local key="${2}"

  if ! grep -q "^${key}" "${file}"; then
      # Key does not exist, add it.
      echo "${key}" >> "${file}"
  fi
}

#######################
# Takes two arguments: file, and key.
# Deletes a key or key/value pair from target file
#
# Example usage:
# removeKey "/etc/pihole/setupVars.conf" "PIHOLE_DNS_1"
#######################
removeKey() {
  local file="${1}"
  local key="${2}"
  sed -i "/^${key}/d" "${file}"
}

#######################
# returns FTL's current telnet API port
#######################
getFTLAPIPort(){
  local FTLCONFFILE="/etc/pihole/pihole-FTL.conf"
  local DEFAULT_PORT_FILE="/run/pihole-FTL.port"
  local DEFAULT_FTL_PORT=4711
  local PORTFILE
  local ftl_api_port

  if [ -f "$FTLCONFFILE" ]; then
    # if PORTFILE is not set in pihole-FTL.conf, use the default path
    PORTFILE="$( (grep "^PORTFILE=" $FTLCONFFILE || echo "$DEFAULT_PORT_FILE") | cut -d"=" -f2-)"
  fi

  if [ -s "$PORTFILE" ]; then
    # -s: FILE exists and has a size greater than zero
    ftl_api_port=$(cat "${PORTFILE}")
    # Exploit prevention: unset the variable if there is malicious content
    # Verify that the value read from the file is numeric
    expr "$ftl_api_port" : "[^[:digit:]]" > /dev/null && unset ftl_api_port
  fi

  # echo the port found in the portfile or default to the default port
  echo "${ftl_api_port:=$DEFAULT_FTL_PORT}"
}
