job "consul" {
  datacenters = ["dc1"]
  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }
  group "consul" {
    count = 3
    network {
      # https://developer.hashicorp.com/consul/docs/install/ports#consul-servers
      port "dns" {
        static = 8600
      }
      port "http" {
        static = 8500
      }
      port "https" {
        static = 8501
      }
      port "grpc" {
        static = 8502
      }
      port "grpc-tls" {
        static = 8503
      }
      port "server-rpc" {
        static = 8300
      }
      port "lan-serf" {
        static = 8301
      }
      port "wan-serf" {
        static = 8302
      }
    }
    volume "consul" {
      type = "host"
      source = "consul"
      read_only = false
    }
    task "consul" {
      driver = "docker"
      config {
        image = "hashicorp/consul:1.18.1"
        # we disable host-node-id because we run consul within nomad, meaning the host-node-ids are non-deterministic and change per container
        args = ["agent", "-config-dir=local", "-disable-host-node-id"]
        ports = ["dns","http","https","grpc","grpc-tls","server-rpc", "lan-serf","wan-serf"]
      }
      service {
        name = "consul-nomad"
        tags = [ "urlprefix-consul/" ]
        port = "http"
        check {
            type     = "http"
            path     = "/v1/status/leader"
            interval = "20s"
            timeout  = "5s"
        }
      }
      volume_mount {
        volume      = "consul"
        destination = "/consul/data"
        read_only = false
      }

      template {
        data = <<EOF
# Full configuration options can be found at https://www.consul.io/docs/agent/config
datacenter = "dc1"

client_addr = "0.0.0.0"

ui_config{
  enabled = true
}

server = true
bootstrap_expect = 3
advertise_addr = "{{ env "attr.unique.network.ip-address" }}"
retry_join = ["10.0.0.166:8301","10.0.0.107:8301","10.0.0.181:8301"]
EOF

        destination = "local/consul.hcl"
      }
    }
  }
}
