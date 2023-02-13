#!/usr/bin/env bash

log_info() { echo "$(date) - INFO: $1"; }
log_err() { echo "$(date) - ERROR: $1" >&2; }

main() {
    local ret

    should_be_updated
    ret=$?

    if [ $ret -eq 1 ]; then
        update_openstacksdk || return 1
        return 0
    elif [ $ret -eq 2 ]; then
        return 1
    fi

    log_info "The system is no need to update openstacksdk."

    return 0
}

# Detect whether the update is necessary or not.
# Return codes are below.
#   0: The system does not necessary to update openstacksdk.
#   1: The system necessary to update openstacksdk.
#   2: Some error occured.
should_be_updated() {
    # Read variables to detect this environment.
    source /etc/lsb-release || {
        log_err "Could not load /etc/lsb-release. The file might not be existed or the file does not have a read permission."
        return 2
    }

    if [ "${DISTRIB_ID}" = "Ubuntu" -a "${DISTRIB_RELEASE}" = "22.04" ]; then
        return 1
    fi

    return 0
}

update_openstacksdk() {
    pip install openstacksdk==1.* || {
        log_err "Failed to install/update openstack sdk to 1.*"
        return 1
    }

    return 0
}

main "$@"
