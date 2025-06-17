#!/bin/bash
set -euo pipefail

sudo apt install -y rustc cargo

rustc --version
cargo --version
