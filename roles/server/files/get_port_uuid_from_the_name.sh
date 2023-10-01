#!/usr/bin/env bash

log_err() {
    echo "$(date) - ERROR: $1" >&2
}

main() {
    local port_name="$1"
    local output num_of_ports port_id

    if [ -z "${port_name}" ]; then
        log_err "This script requires \"port_name\" as argument. ($0 <port-name>)"
        return 1
    fi

    # Getting plain output of the command "openstack port list"
    output="$(openstack port list --name "${port_name}" --format json >&2)"
    ret=$?
    if [ $ret -ne 0 ]; then
        log_err "Failed to get list of ports because a command \"openstack port list --name "${port_name}" --format json\" returned non 0. ReturnCode=${ret}, Output=${output}"
        return 1
    fi

    if [ -z "${stdout}" ]; then
        log_err "Failed to get list of ports. Because code that is returned was 0 but the output of \"openstack port list --name "${port_name}" --format json\" was empty."
        return 1
    fi

    # Getting num_of_ports
    num_of_ports="$(jq -r '. | length' <<< "${output}")"
    ret=$?
    if [ $ret -ne 0 ]; then
        log_err "Failed to get num of ports. Because a command \"jq -r '. | length' <<< \\\"${output}\\\" returns code \"${ret}\"."
        return 1
    fi
    if [[ ! "${num_of_ports}" =~ ^[0-9]+$ ]]; then
        log_err "Failed to get num of ports. Because a output of a command \"jq -r '. | length' <<< \\\"${output}\\\" was not numeric one. Num of ports ${num_of_ports}. Target JSON ${output}"
        return 1
    fi
    if [ "${num_of_ports}" -ne 1 ]; then
        log_err "Failed to get ports. This script expects only 1 port that has a name \"${port_name}\" but found ${num_of_ports} port(s). Target JSON ${output}"
        return 1
    fi

    # Getting num_of_ports
    port_id="$(jq -r '.[0].ID' <<< "${output}")"
    if [[ ! "${port_id}" =~ ^[0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12}$ ]]; then
        log_err "Failed to get \"port_id\" because its format was invalid. port_id=${port_id},command=\"jq -r '.[0].ID' <<< \\\"${output}\\\"\""
        return 1
    fi

    echo $port_id

    return 0
}

main "$@"
