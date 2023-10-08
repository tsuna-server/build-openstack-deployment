#!/usr/bin/env bash
log_err() { echo "$(date) - ERROR: $1" >&2; }
log_info() { echo "$(date) - INFO: $1"; }

main() {
    local ret instance

    declare -a running_instances=()
    running_instances=($(openstack server list --long --format json | jq -r '.[] | select(.["Power State"] == 1) | .Name'))
    ret=$?
    [ $ret -ne 0 ] && {
        log_err "Failed to get running instances by running the command \"openstack server list --long --format json | jq -r '.[] | select(.[\"Power State\"] == 1) | .Name'\"."
        return 1
    }

    [ ${#running_instances[@]} -eq 0 ] && {
        log_info "There are no instances that should be shut off."
        return 0
    }

    for instance in "${running_instances[@]}"; do
        openstack server stop "${instance}" || {
            log_err "Failed to stop by running the command \"openstack server stop ${instance}\"."
            return 1
        }
    done

    # Wait until all instances have stopped.
    local max_attempts=360
    local current_attempts=0
    local count_of_instances

    while [ $current_attempts -lt $max_attempts ]; do
        running_instances=$(openstack server list --long --format json | jq -r '. | select(.[0]["Power State"] == 1) | length')
        ret=$?

        if [ $ret -ne 0 ]; then
            log_err "A return code of the command \"openstack server list --long --format json | jq -r '. | select(.[0][\\\"Power State\\\"] == 1) | length'\" is $ret"
            return 1
        fi
        if [ -z "$running_instances" ] || [ $running_instances -eq 0 ]; then
            log_info "Succeeded in shutting off all instances."
            return 0
        fi

        (( ++current_attempts ))
        log_info "$running_instances instances are still running. Waiting for stopping them. (current_attempts=${current_attempts})"
        sleep 2
    done

    return 1
}

main "$@"
