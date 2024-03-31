job "fabio" {
  datacenters = ["dc1"]
  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }
  group "fabio" {
    count = 3
    network {
      mode = "host"
    }
    task "fabio" {
      driver = "docker"
      config {
        image = "ghcr.io/jrcichra/fabio:sha-3f9d547c"
        args = ["-cfg", "local/fabio.properties"]
        network_mode = "host"
      }
      template {
        data = <<EOF
registry.consul.addr = {{ env "attr.unique.network.ip-address" }}:8500

# settings for BGP

#bgp.enabled = true
#bgp.asn = 64512
#bgp.anycastaddresses = 10.0.2.0/24
#bgp.routerid = {{ env "attr.unique.network.ip-address" }}
#bgp.peers = address=10.0.0.1
#proxy.addr = 10.0.2.1:80
EOF
        destination = "local/fabio.properties"
      }
    }
  }
}