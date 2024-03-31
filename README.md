# nomad-cluster

A highly-available `nomad` cluster configuration. Unplug a node and everything still works. Uses GitOps.

Currently used in a 3 node Raspberry Pi cluster, where all systems are both `servers` and `clients`. All images are built for `amd64` and `arm64`.

# Prerequisites

- 3 systems to run `nomad`
- 1 system for `ansible`

# Tools

- `ansible` - configure platform
- `nomad` - scheduler / orchestrator
- `consul` - service discovery
- `fabio` - load balancer (can be configured with BGP)
- `nomad-gitops-operator/git-sync` (fork) - reconciles and applies `.nomad` files in git repo
- `whoami` - (fork) - example web app to show off resilience

# Design choices

`nomad` is the only service deployed through `systemd`. Everything else is a `nomad` job.

Some deployments use `consul` as a way to bootstrap `nomad`. Given this is a more "nomad from scratch" repo,
I've used `consul` as just a tool for configuring `fabio`. In this configuration `consul` can also be easily upgraded.

`fabio` was chosen because it integrates with `consul` and `nomad` very well. `nomad` services can provide `consul` tags, which `fabio` uses to configure itself.

The state of our `nomad` cluster lives in `git` and is continuously reconciled. This is more automatic than using something like `terraform`.

# Setup and Testing

- Fork the repository so you can customize it.
- Configure [ansible/inventory](ansible/inventory) with the IPs of your `servers` and `clients`. Set `fabio_ip` to an IP address you want highly available for your web services if using BGP.
- Change [jobs/consul.nomad](jobs/consul.nomad)'s `retry_join` IPs to match yours.
- Run `ansible-playbook -i inventory setup.yml`
- Navigate to one of the IP addresses on port `4646` to see the `nomad` dashboard.
- Bootstrap GitOps by manually applying `jobs/nomad-gitops-operator.nomad`.
- If you use a private repo, add the secrets to nomad variables under `nomad/jobs/nomad-gitops-operator`.
- This will deploy `consul`, `fabio`, and `whoami`.
- You can access `consul` on port `8500` on any node.
- `fabio` is accessible on port `9999` on any node.
- The provided `fabio` configuration does not enable BGP, but provides all the options for you to configure BGP. I recommend this to provide highly available web services.
- The `whoami` tasks are available via `<node-name>:9999/whoami`. Each time you refresh you will get the container hostname of a task.
- Unplug a node and see that `nomad`, `consul`, `fabio`, and `whoami` all still work. If using BGP, there should be no need to change the IP address / hostname you're using.
