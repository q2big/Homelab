# Grafana

Resource usage history for the Proxmox host and its VMs: CPU, memory, disk and network over time, per VM. Proxmox sends metrics to InfluxDB 2, and Grafana shows them. Both run in Docker on the SIEM VM.

Only reachable from Trusted. Never exposed to the internet.

## Architecture

```
Proxmox host ──HTTPS 8086──▶ SOC VLAN
                             └─ SIEM VM
                                ├─ Docker: influxdb (bucket proxmox, 90 days)
                                └─ Docker: grafana ──▶ influxdb (internal network)
Trusted ─────HTTPS 3000─────▶ grafana
```

## Security design

- **Least-privilege tokens.** Proxmox has a token that can only write to the `proxmox` bucket. Grafana has a read-only token for the organization, which holds nothing but these metrics. 
- **TLS everywhere.** A self-signed certificate for InfluxDB and Grafana. The Proxmox host trusts it, so the metric server verifies the certificate before it sends the token.
- **Hardened containers.** Non-root, `cap_drop: ALL`, `no-new-privileges`, memory limits so they never starve Wazuh.
- **No telemetry.** Usage reporting and news are off in InfluxDB and Grafana.

## Setup

```bash
sudo mkdir -p /opt/metrics/{influxdb/data,influxdb/config,grafana,certs} && cd /opt/metrics
sudo openssl req -x509 -newkey rsa:3072 -nodes -days 1825 \
  -keyout certs/metrics.key -out certs/metrics.crt -subj "/CN=metrics" \
  -addext "subjectAltName=IP:<vm-ip>,DNS:influxdb"
sudo install -o 1000 -g 1000 -m 400 certs/metrics.key certs/influxdb.key
sudo install -o 472 -g 0 -m 400 certs/metrics.key certs/grafana.key
sudo rm certs/metrics.key && sudo chown -R 1000:1000 influxdb && sudo chown -R 472:0 grafana
# copy compose.yaml and .env.example here, then:
sudo cp .env.example .env && sudo chmod 600 .env   # fill in .env
sudo docker compose up -d
```

## Operations

### Tokens

A bucket-scoped read token is not enough for Grafana: `buckets()` also needs read access to the organization and all its buckets. Use the InfluxDB API with `curl` to manage tokens, since `influx auth list` hangs in this setup.

### Update

Change the image tags in `compose.yaml`, then:

```bash
cd /opt/metrics && sudo docker compose pull && sudo docker compose up -d
```

### Logs

`sudo docker compose logs grafana` or `influxdb`.