#!/bin/bash

# SSH Agent Connection Fix Script
# Handles "Could not open a connection to your authentication agent" error

function ensure_agent_running() {
    # Check if SSH_AUTH_SOCK is set and valid
    if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        echo "SSH agent socket exists at $SSH_AUTH_SOCK"
    else
        echo "No valid SSH agent socket found. Starting new agent..."
        # Start new agent and set environment variables
        eval "$(ssh-agent -s)"
    fi
}

function test_agent() {
    # Test if agent is responsive
    ssh-add -l >/dev/null 2>&1
    local status=$?
    
    case $status in
        0) echo "SSH agent is running and has keys loaded" ;;
        1) echo "SSH agent is running but has no keys" ;;
        2) 
            echo "SSH agent connection failed. Fixing..."
            fix_agent_connection
            ;;
    esac
}

function fix_agent_connection() {
    # Kill any existing ssh-agent processes
    pkill ssh-agent
    
    # Start fresh agent
    eval "$(ssh-agent -s)"
    
    # Set permissions for SSH directory
    if [ -d "~/.ssh" ]; then
        chmod 700 "~/.ssh"
        if [ -f "~/.ssh/id_rsa" ]; then
            chmod 600 "~/.ssh/id_rsa"
        fi
        if [ -f "~/.ssh/id_ed25519" ]; then
            chmod 600 "~/.ssh/id_ed25519"
        fi
    fi
    
    # Add default keys
    for key in id_rsa id_ed25519 id_ecdsa; do
        if [ -f "~/.ssh/$key" ]; then
            ssh-add "~/.ssh/$key" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "Added key: $key"
            fi
        fi
    done
}

function save_agent_info() {
    # Save agent environment variables for other shells
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > "~/.ssh/agent_env"
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >> "~/.ssh/agent_env"
    chmod 600 "~/.ssh/agent_env"
}

# Main execution
echo "Checking SSH agent status..."
ensure_agent_running
test_agent
save_agent_info

echo -e "\nTo connect to this SSH agent in other shells, run:"
echo "source ~/.ssh/agent_env"