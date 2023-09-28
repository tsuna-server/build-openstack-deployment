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

    has_floating_ip_already_existed "$network" "$project" "$floating_ip_address" || return 1
    register_floating_ip "$network" "$subnet" "$project" "$floating_ip_address" || return 1

    return 0
}

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

    if [ "${result_count}" =~ ^(0|1)+$ ]; then
        log_err "Failed to get count of floating_ip. A result of a command \"openstack floating ip list --project "$project" --network "$network" --floating-ip-address "$floating_ip_address" --format json | jq '. | length'\"). Its return code is \"$ret\" is invalid. An actual output is \"${result_count}\"."
        return 2
    fi

    return 0
}

main "$@"
