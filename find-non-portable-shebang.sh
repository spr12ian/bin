#!/usr/bin/env bash
set -euo pipefail

find . -type f -exec awk 'NR==1 && $0=="#!/bin/bash" { print FILENAME }' {} +
