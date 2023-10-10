# Terraform thoughts

If I had to reimplement this module I'd follow a path of reusable modules. 

Firstly, splitting `main.tf ` to separate files e.g. `variables.tf`, `terraform.tf`, `outputs.tf`, `0-network.tf` etc. That would benefit from readability of the module.

Next, I wouldn't use locals for embedding my username in the module. It's mainly my helper variable. If I was implementing this as a module I'd use a variable that would make it distinguishable and would assign its identity to the module. E.g. `name = europe-west-3-test-dev-webserver`

And the final thing for using a module is that we can actually pack it up, semver and post somewhere to store. This way we can have this grannular/moddular way of working with changing module behaviour e.g. adding feature flags like `deploy-something-that-might-break-the-server = true`

... and the installation of those modules would be reeealy easy to implement e.g.

```

module "europe-west-3-test-dev-webserver" {
    source = "<url-to-module-store>/webserver-module/1.0.0.zip"

    some_feature_flag = true
}

module "europe-east-2-test-qa-webserver" {
    source = "<url-to-module-store>/webserver-module/1.0.0.zip"

    some_feature_flag = false
}

```

# Webserver installation

Regarding installation of webserver, we could use a `provisioner` and execute ansible on openstack_compute_instance_v2 but that is not flexible at all... and I just don't like it :D  Also, when refreshing the state it just does not trigger any reinstallation in case of .yaml file change.

If I had to implement this pipeline I'd just make a 2-step pipeline:

1. provision infra - `terraform apply -auto-approve`
2. configure infra - `ansible-playbook -i <pub-ip>, -u ubuntu --private-key <path-to-private-ssh-key> ansible/nginx.yaml`

