job "nomad-gitops-operator" {
  datacenters = ["dc1"]
  group "nomad-gitops-operator" {
    count = 1
    task "git-sync" {
      driver = "docker"
      config {
        image = "registry.k8s.io/git-sync/git-sync:v4.1.0"
      }
      env {
        GITSYNC_ROOT = "${NOMAD_ALLOC_DIR}/repo"
      }
    }
    task "nomad-gitops-operator" {
      driver = "docker"
      config {
        image = "ghcr.io/jrcichra/nomad-gitops-operator:sha-6ab174ca"
        command = "/nomad-gitops-operator"
        args    = ["--address=http://${attr.unique.network.ip-address}:4646", "bootstrap", "fs", "--base-dir=${NOMAD_ALLOC_DIR}/repo/nomad-cluster.git", "--path", "jobs/*.nomad", "--watch", "--delete=false"]
      }
    }
  }
}
