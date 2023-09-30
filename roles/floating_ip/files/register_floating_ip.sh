#!/usr/bin/env bash

log_err() {
    echo "$(date) - ERROR: $1" >&2
}
log_info() {
    echo "$(date) - INFO: $1"
}

main() {
    local network="$1"
    local subnet="$2"
    local project="$3"
    local floating_ip_address="$4"

    if [ ${#@} -ne 4 ]; then
        log_err "$0 requires 4 arguments but found ${#@} arguments."
        print_usage
        return 1
    fi

    if [ -z "$network" ]; then
        log_err "This script ($0) requires name of network as 1st argument but found it as empty."
        print_usage
        return 1
    fi

    if [ -z "$subnet" ]; then
        log_err "This script ($0) requires name of subnet as 2nd argument but found it as empty."
        print_usage
        return 1
    fi

    if [ -z "$project" ]; then
        log_err "This script ($0) requires name of project as 3rd argument but found it as empty."
        print_usage
        return 1
    fi

    if [[ "$floating_ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_err "This script ($0) requires floating IP address as 4th argument but found it empty or wrong format."
        print_usage
        return 1
    fi

    has_floating_ip_already_existed "$network" "$project" "$floating_ip_address" || return 1
    register_floating_ip "$network" "$subnet" "$project" "$floating_ip_address" || return 1

    return 0
}

print_usage() {
    log_err "Usage:"
    log_err "  $0 <network> <subnet> <project> <floating_ip_address>"
}

# Regsiter floating IP.
# This function never check whether the IP has already existed.
# This function will return non 0 if the IP has already registered.
register_floating_ip() {
    local network="$1"
    local subnet="$2"
    local project="$3"
    local floating_ip_address="$4"

    local output ret
    output="$(openstack floating ip create --project "$project" --subnet "$subnet" --floating-ip-address "$floating_ip_address" --format json "$network" 2>&1)"
    ret=$?

    if [ $ret -ne 0 ]; then
        log_err "Failed to create floating IP with command \"openstack floating ip create --project "$project" --subnet "$subnet" --floating-ip-address "$floating_ip_address" --format json "$network" 2>&1\". Its return code is \"$ret\"."
        return 1
    fi

    return 0
}

# Check the floating IP has already created or not.
#   Return 0: floating IP has not created so far
#   Return 1: floating IP has already created
#   Return 2: Internal error has occured
has_floating_ip_already_existed() {
    local network="$1"
    local project="$2"
    local floating_ip_address="$3"

    local result_count ret

    result_count="$(openstack floating ip list --project "$project" --network "$network" --floating-ip-address "$floating_ip_address" --format json | jq '. | length')"
    ret=$?

    if [ $ret -ne 0 ]; then
        log_err "Failed to get count of floating_ip with a command \"openstack floating ip list --project "$project" --network "$network" --floating-ip-address "$floating_ip_address" --format json | jq '. | length'\"). Its return code is \"$ret\""
        return 2
    fi

    if [[ ! "${result_count}" =~ ^[0-9]+$ ]]; then
        log_err "Failed to get count of floating_ip. A result of a command \"openstack floating ip list --project "$project" --network "$network" --floating-ip-address "$floating_ip_address" --format json | jq '. | length'\"). Its return code is \"$ret\" is invalid. An actual output is \"${result_count}\"."
        return 2
    fi

    if [ -z "${result_count}" ]; then
        return 0
    fi

    if [ ${result_count} -eq 0 ]; then
        return 0
    fi

    return 1
}

main "$@"
