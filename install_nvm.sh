#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────
# CONFIGURATION
# ────────────────────────────────────────────────────────────────
NVM_DIR="${HOME}/.nvm"

# ────────────────────────────────────────────────────────────────
# FUNCTIONS
# ────────────────────────────────────────────────────────────────

print_info() {
    echo -e "\e[36mINFO:\e[0m $1"
}

print_success() {
    echo -e "\e[32mSUCCESS:\e[0m $1"
}

print_error() {
    echo -e "\e[31mERROR:\e[0m $1"
}

# ────────────────────────────────────────────────────────────────
# MAIN SCRIPT
# ────────────────────────────────────────────────────────────────

if [ -d "$NVM_DIR" ]; then
    print_success "nvm is already installed at $NVM_DIR"
else
    print_info "Fetching latest nvm release version..."

    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install jq to parse JSON responses."
        exit 1
    fi
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed. Please install curl to download nvm."
        exit 1
    fi
    latest_version=$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | jq -r .tag_name | sed 's/^v//')

    if [[ -z "$latest_version" ]]; then
        print_error "Failed to retrieve the latest nvm version."
        exit 1
    fi

    print_info "Latest nvm version is: v$latest_version"
    print_info "Installing nvm v$latest_version..."

    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${latest_version}/install.sh" | bash >/dev/null 2>&1

    if [ -d "$NVM_DIR" ]; then
        print_success "nvm v$latest_version installed successfully."

        # Make nvm available in the current shell
        export NVM_DIR="$NVM_DIR"
        # shellcheck disable=SC1090
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        print_info "nvm is now ready to use in this shell."

        nvm install --lts
    else
        print_error "Installation completed, but nvm directory not found!"
        exit 1
    fi
fi
