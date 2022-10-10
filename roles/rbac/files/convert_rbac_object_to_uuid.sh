#!/usr/bin/env bash

main() {
    local object_type="$1"
    local object_id="$2"
    local domain="$3"
    local project_id="$4"

    local object_uuid

    if [[ "$object_id" =~ ^[0-9a-zA-Z]{8}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{12}$ ]]; then
        echo "$object_id"
        return 0
    fi

    if [ ! "$object_type" = "network" ]; then
        echo "ERROR: This script only support object_type == \"network\" so far. You specified \"object_id == ${object_id}\"" >&2
        return 1
    fi

    object_uuid="$(jq -r '.[] | .ID' < <(openstack network list --name "${object_id}" --project-domain "${domain}" --project "${project_id}" --format json))"

    if [[ ! "$object_uuid" =~ ^[0-9a-zA-Z]{8}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{12}$ ]]; then
        echo "ERROR: Failed to get object_uuid. [command=\"openstack network list --name "${object_id}" --project-domain "${domain}" --project "${project_id}" --format json\"]" >&2
        return 1
    fi

    echo "$object_uuid"

    return 0
}

main "$@"
