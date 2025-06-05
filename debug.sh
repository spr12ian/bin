#!/bin/bash

debug() {
  if [[ "${DEBUG:-}" == "true" ]]; then
    "$@"
  else
    "$@" &>/dev/null
  fi
}

