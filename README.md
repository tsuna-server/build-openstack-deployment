# build-openstack-deployment
This is a repository of Ansible playbooks to build OpenStack deployment mainly instances on OpenStack.

```
$ docker run --rm \
    --add-host dev-controller01:${ip_of_dev_controller01} \
    --volume ${PWD}:/opt/ansible \
    --volume /path/to/private-key:/private-key \
    -ti tsutomu/tsuna-ansible-runner \
    -i production -l dev-controller01 site.yml
```

