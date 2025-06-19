#!/usr/bin/env bash
set -euo pipefail

find . -type f -name '*.sh' -exec sed -i '1s|^#! */bin/bash|#!/usr/bin/env bash|' {} +

