#!/bin/bash

EASY_RSA=/usr/share/easy-rsa

info() {
    echo "[+] $1"
}

# Phase 1 is the generation of the keys
# and an editable server configuration file.
phase1() {
    cd /data

    # Generate keys.
    if [[ ! -d /data/pki ]]; then
        "$EASY_RSA"/easyrsa init-pki
        "$EASY_RSA"/easyrsa build-ca nopass
        "$EASY_RSA"/easyrsa build-server-full server nopass
        "$EASY_RSA"/easyrsa gen-dh
    fi

    # Make some directories and prepare the config.
    mkdir -p /data/clients
    mkdir -p /data/logs
    cp /server.cfg /data/server.cfg
    cp /client.cfg /data/client.cfg

    info "The keys have been generated. Please"
    info "edit the server.cfg and client.cfg"
    info "in your data directory."
    exit 0
}

# Phase 2 is the final phase, it's running the
# OpenVPN server with the custom config and keys.
phase2() {
    openvpn --status /data/logs/server-status.log --status-version 2 --suppress-timestamps --config /data/server.cfg
}

# Generates a single profile for client use
# in the /data/clients folder.
generate_client() {
    cd /data

    # Copy the basic client if that
    # has not happened yet.
    if [[ ! -f /data/client.cfg ]]; then
        cp /client.cfg /data/client.cfg
    fi

    # Begin with making keys for the client.
    "$EASY_RSA"/easyrsa build-client-full "$1" nopass

    # Copy the basic profile.
    cp /data/client.cfg /data/clients/"$1".ovpn

    # Embed the key information.
    echo "<ca>" >> /data/clients/"$1".ovpn
    cat /data/pki/ca.crt >> /data/clients/"$1".ovpn
    echo "</ca>" >> /data/clients/"$1".ovpn

    echo "<cert>" >> /data/clients/"$1".ovpn
    cat /data/pki/issued/"$1".crt >> /data/clients/"$1".ovpn
    echo "</cert>" >> /data/clients/"$1".ovpn

    echo "<key>" >> /data/clients/"$1".ovpn
    cat /data/pki/private/"$1".key >> /data/clients/"$1".ovpn
    echo "</key>" >> /data/clients/"$1".ovpn

    info "Client profile generated: <data>/clients/$1.ovpn"
    exit 0
}

## Start of the script.
# Generating client profiles.
if [[ "$1" == "make-client" ]]; then
    if [[ -z "$2" ]]; then
        info "Usage: make-client <name>"
        exit 1
    fi

    generate_client "$2"
fi

# No arguments, so create keys or run the server.
if [[ ! -d /data/pki ]]; then
    info "Keys not found. Generating."
    phase1
fi

if [[ ! -f /data/server.cfg ]]; then
    info "Server configuration not found. Generating everything again."
    phase1
fi

# Start the server.
info "Everything OK, starting server."
phase2
