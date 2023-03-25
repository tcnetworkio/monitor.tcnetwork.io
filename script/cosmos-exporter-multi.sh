#!/usr/bin/env bash

read -p "Enter denom value (ex: uatom for Atom): " BOND_DENOM
read -p "Enter prefix value (cosmos for Atom): " BENCH_PREFIX
read -p "Enter custom port (default is 9300): " CUSTOM_PORT
read -p "Enter custom port (default is 26): " NODE_PORT


echo '================================================='
echo -e "denom: \e[1m\e[32m$BOND_DENOM\e[0m"
echo -e "prefix: \e[1m\e[32m$BENCH_PREFIX\e[0m"
echo -e "service port: \e[1m\e[32m$CUSTOM_PORT7\e[0m"
echo -e "node port: \e[1m\e[32m$NODE_PORT\e[0m"
echo '================================================='
sleep 3

echo -e "\e[1m\e[32mInstalling cosmos-exporter... \e[0m" && sleep 1

# install cosmos-exporter
if [ ! -f "/usr/bin/cosmos-exporter" ]; then
  echo -e "\e[1m\e[32mDownloading binary... \e[0m" && sleep 1

  wget https://github.com/solarlabsteam/cosmos-exporter/releases/download/v0.3.0/cosmos-exporter_0.3.0_Linux_x86_64.tar.gz
  tar xvfz cosmos-exporter_*.*_Linux_x86_64.tar.gz
  sudo cp ./cosmos-exporter /usr/bin
  rm cosmos-exporter_* -rf
fi

# create new user
echo -e "\e[1m\e[32mCreating user... \e[0m" && sleep 1

sudo useradd -rs /bin/false cosmos_exporter_$BENCH_PREFIX

# create systemd service
echo -e "\e[1m\e[32mCreating service... \e[0m" && sleep 1

sudo tee <<EOF >/dev/null /etc/systemd/system/cosmos-exporter-$BENCH_PREFIX.service
[Unit]
Description=$BENCH_PREFIX Cosmos Exporter
After=network-online.target

[Service]
User=cosmos_exporter_$BENCH_PREFIX
Group=cosmos_exporter_$BENCH_PREFIX
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=cosmos-exporter --denom $BOND_DENOM --bech-prefix $BENCH_PREFIX --listen-address ":$CUSTOM_PORT" \
  --node "localhost:${NODE_PORT}090" \
  --tendermint-rpc "http://localhost:${NODE_PORT}657" \
  --denom-coefficient 1000000000000000000
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

# start systemd service
sudo systemctl daemon-reload
sudo systemctl enable cosmos-exporter-$BENCH_PREFIX.service
sudo systemctl start cosmos-exporter-$BENCH_PREFIX.service

echo -e "\e[1m\e[32mInstallation finished... \e[0m" && sleep 1
echo -e "\e[1m\e[32mPlease make sure port $CUSTOM_PORT is open \e[0m" && sleep 1
echo -e "\e[1m\e[32mCheck the logs with command 'sudo journalctl -u cosmos-exporter-$BENCH_PREFIX -f --output cat' \e[0m" && sleep 1
