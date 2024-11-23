#!/bin/bash

# SSH Agent Management Script
# This script handles SSH agent initialization and key management

SSH_ENV="~/.ssh/agent-environment"

function start_agent {
    echo "Starting new SSH agent..."
    # Start SSH agent and save environment variables
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    
    # Add default keys (modify this list as needed)
    if [ -f "~/.ssh/id_rsa" ]; then
        ssh-add "~/.ssh/id_rsa"
    fi
    if [ -f "~/.ssh/id_ed25519" ]; then
        ssh-add "~/.ssh/id_ed25519"
    fi
}

function check_agent {
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        # Check if agent is still running
        ps -ef | grep "${SSH_AGENT_PID}" | grep ssh-agent > /dev/null || {
            start_agent;
        }
    else
        start_agent;
    fi
}

function list_keys {
    ssh-add -l
}

function add_key {
    if [ -z "$1" ]; then
        echo "Please specify the path to the key file"
        return 1
    fi
    ssh-add "$1"
}

function remove_key {
    if [ -z "$1" ]; then
        echo "Please specify the path to the key file"
        return 1
    fi
    ssh-add -d "$1"
}

function kill_agent {
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        echo "Killing SSH agent ${SSH_AGENT_PID}..."
        eval "$(ssh-agent -k)"
        rm "${SSH_ENV}"
    else
        echo "No SSH agent found"
    fi
}

# Main script logic
case "$1" in
    "start")
        check_agent
        ;;
    "list")
        list_keys
        ;;
    "add")
        add_key "$2"
        ;;
    "remove")
        remove_key "$2"
        ;;
    "kill")
        kill_agent
        ;;
    *)
        echo "Usage: $0 {start|list|add <keyfile>|remove <keyfile>|kill}"
        exit 1
        ;;
esac