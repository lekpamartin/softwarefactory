softwarefactory
========


# Install

Clone and run those commands: You need to edit softwarefactory.conf

```bash
git clone https://github.com/lekpamartin/softwarefactory.git
cd softwarefactory
vi softwarefactory.conf
./softwarefactory.sh up
```

Prerequisites:

* Docker Engine >= 1.13
* Docker Compose >= 1.11

Containers:

* Prometheus (metrics database) `http://<host-ip>:9090`
* Prometheus-Pushgateway (push acceptor for ephemeral and batch jobs) `http://<host-ip>:9091`
* AlertManager (alerts management) `http://<host-ip>:9093`
* Grafana (visualize metrics) `http://<host-ip>:3000`
* NodeExporter (host metrics collector)
* cAdvisor (containers metrics collector)
* Caddy (reverse proxy and basic auth provider for prometheus and alertmanager)






# Doc
Forked from [stefanprodan/dockprom](https://github.com/stefanprodan/dockprom)
