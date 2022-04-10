#!/usr/bin/env bash

echo -e "\e[1m\e[32mInstalling node-exporter... \e[0m" && sleep 1

# install node-exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/
rm node_exporter-* -rf

# create new user
sudo useradd -rs /bin/false node_exporter

# create systemd service
sudo tee <<EOF >/dev/null /etc/systemd/system/node-exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# start systemd service
sudo systemctl daemon-reload
sudo systemctl enable node-exporter.service
sudo systemctl start node-exporter.service

echo -e "\e[1m\e[32mInstallation finished... \e[0m" && sleep 1
echo -e "\e[1m\e[32mPlease make sure port 9100 is open \e[0m" && sleep 1
echo -e "\e[1m\e[32mVerify with command 'curl http://localhost:9100/metrics' \e[0m" && sleep 1
