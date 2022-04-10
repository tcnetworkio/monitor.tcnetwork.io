#!/usr/bin/env bash

read -p "Enter denom value (ex: uatom for Atom): " BOND_DENOM
read -p "Enter prefix value (cosmos for Atom): " BENCH_PREFIX

echo '================================================='
echo -e "denom: \e[1m\e[32m$BOND_DENOM\e[0m"
echo -e "prefix: \e[1m\e[32m$BENCH_PREFIX\e[0m"
echo '================================================='
sleep 3

echo -e "\e[1m\e[32mInstalling cosmos-exporter... \e[0m" && sleep 1

# install cosmos-exporter
wget https://github.com/solarlabsteam/cosmos-exporter/releases/download/v0.3.0/cosmos-exporter_0.3.0_Linux_x86_64.tar.gz
tar xvfz cosmos-exporter_*.*_Linux_x86_64.tar.gz
sudo cp ./cosmos-exporter /usr/bin
rm cosmos-exporter_* -rf

# create new user
sudo useradd -rs /bin/false cosmos_exporter

# create systemd service
sudo tee <<EOF >/dev/null /etc/systemd/system/cosmos-exporter.service
[Unit]
Description=Cosmos Exporter
After=network-online.target

[Service]
User=cosmos_exporter
Group=cosmos_exporter
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=cosmos-exporter --denom $BOND_DENOM --denom-coefficient 1000000 --bech-prefix $BENCH_PREFIX
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

# start systemd service
sudo systemctl daemon-reload
sudo systemctl enable cosmos-exporter.service
sudo systemctl start cosmos-exporter.service

echo -e "\e[1m\e[32mInstallation finished... \e[0m" && sleep 1
echo -e "\e[1m\e[32mPlease make sure port 9300 is open \e[0m" && sleep 1
echo -e "\e[1m\e[32mCheck the logs with command 'sudo journalctl -u cosmos-exporter -f --output cat' \e[0m" && sleep 1
