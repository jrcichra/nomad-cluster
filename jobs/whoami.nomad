job "whoami" {
  datacenters = ["dc1"]
  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }
  group "whoami" {
    count = 3
    network {
      port "http" {
        to = 8080
      }
    }
    task "whoami" {
      driver = "docker"
      config {
        image = "ghcr.io/jrcichra/whoami"
        ports = ["http"]
      }
      service {
        name = "whoami"
        tags = [ "urlprefix-whoami/", "urlprefix-/whoami strip=/whoami" ]
        port = "http"
        check {
            type     = "http"
            path     = "/"
            interval = "20s"
            timeout  = "5s"
        }
      }
    }
  }
}