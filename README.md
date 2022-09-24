# build-openstack-deployment
This is a repository of Ansible playbooks to build OpenStack deployment mainly instances on OpenStack.

## Dependencies
This project is depends on a collection (Openstack.Cloud)[https://docs.ansible.com/ansible/latest/collections/openstack/index.html].
It already declared in `requirements.yml` and you can install it with the command like below.

```
$ ansible-galaxy install -r requirements.yml
```

## Run it on a Docker container
You can run this Ansible project by using a container `tsutomu/tsuna-ansible-runner`.

```
$ docker run --rm \
    --add-host dev-controller01:${ip_of_dev_controller01} \
    --volume ${PWD}:/opt/ansible \
    --volume /path/to/private-key:/private-key \
    -ti tsutomu/tsuna-ansible-runner \
    -i production -l dev-controller01 site.yml
```

