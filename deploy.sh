#!/bin/bash

# exit immediately if a command exits with a non-zero status
set -e
steam_user=steam
log_path=/tmp/pal_server.log

# Check if the steam user exists, and create it if it doesn't
if getent passwd "$steam_user" >/dev/null 2>&1; then
    echo "User $steam_user exists."
else
    echo "User $steam_user does not exist. Adding $steam_user ..."
    sudo useradd -m -s /bin/bash $steam_user
fi



# Begin installation of SteamCMD
echo "Installing SteamCMD..."

# Install dependencies
sudo yum install glibc.i686 libstdc++.i686 -y > $log_path

# Install steamcmd
steam_user_home_dir=$(eval echo ~$steam_user)
sudo -u $steam_user mkdir -p $steam_user_home_dir/Steam/ >> $log_path
sudo -u $steam_user mkdir -p $steam_user_home_dir/.steam/sdk64/ >> $log_path

echo "Downloading SteamCMD..."
sudo -u $steam_user sh -c "curl -sqL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxvf - -C $steam_user_home_dir/Steam" >> $log_path

# shellcheck disable=SC2016
steamcmd_path=$steam_user_home_dir/Steam/steamcmd.sh
sudo -u $steam_user echo "alias steamcmd=$steamcmd_path" >> ~/.bashrc

echo "Downloading SDK..."
sudo -u $steam_user $steamcmd_path +login anonymous +app_update 1007 validate +quit >> $log_path
sudo -u $steam_user $steamcmd_path +login anonymous +app_update 2394010 validate +quit >> $log_path

sudo cp "$steam_user_home_dir/Steam/steamapps/common/Steamworks SDK Redist/linux64/steamclient.so" "$steam_user_home_dir/.steam/sdk64/"

systemd_unit=pal-server
cat <<EOF > $systemd_unit.service
[Unit]
Description=$systemd_unit.service

[Service]
Type=simple
User=$steam_user
Restart=on-failure
RestartSec=30s
ExecStart=$steam_user_home_dir/Steam/steamapps/common/PalServer/PalServer.sh -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS

[Install]
WantedBy=multi-user.target
EOF

sudo mv $systemd_unit.service /usr/lib/systemd/system/

echo "Starting pal-server.service..."
sudo systemctl enable $systemd_unit
sudo systemctl restart $systemd_unit
sudo systemctl -l --no-pager status $systemd_unit

if systemctl --quiet is-active "$systemd_unit"
then
    echo -e "\nPalServer is running successfully, enjoy!"
else
    echo -e "\nThere were some problems with the installation, please check the log $log_path."
fi
