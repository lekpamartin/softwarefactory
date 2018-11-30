softwarefactory
========


# Install

Clone the repo

```bash
git clone https://github.com/lekpamartin/softwarefactory.git
```

Prerequisites:

* Docker Engine >= 1.13
* Docker Compose >= 1.11

## Run
Run those commands: You need to edit softwarefactory.conf

```bash
cd softwarefactory
vi softwarefactory.conf
./softwarefactory.sh up
```

Containers:

* Prometheus (metrics database) `http://<host-ip>:9090`
* Prometheus-Pushgateway (push acceptor for ephemeral and batch jobs) `http://<host-ip>:9091`
* AlertManager (alerts management) `http://<host-ip>:9093`
* Grafana (visualize metrics) `http://<host-ip>:3000`
* NodeExporter (host metrics collector)
* cAdvisor (containers metrics collector)
* Caddy (reverse proxy and basic auth provider for prometheus and alertmanager)

## Stop
Run those commands: 

```bash
cd softwarefactory
./softwarefactory.sh down
```

## Destroy
Run those commands:

```bash
cd softwarefactory
./softwarefactory.sh destroy
```



# Doc
Forked from [stefanprodan/dockprom](https://github.com/stefanprodan/dockprom)
