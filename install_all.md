# Install instructions for steps other than install.sh

## Install Ubuntu

Ubuntu 20.04

## Create terminal

   Ctrl+Option+T

## Set up SSH and connect from remote computer

```
sudo apt update
sudo apt upgrade

sudo apt-get install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

ssh locobot@192.168.1.141
```

## Install ROS software etc.

```
wget https://raw.githubusercontent.com/ravescovi/locobot/main/install.sh
chmod +x install.sh
# Next will likely prompt for password (sudo)
./install.sh
```

## Install Virtual GL on Ubuntu

[See https://gist.github.com/cyberang3l/422a77a47bdc15a0824d5cca47e64ba2]
  
```
wget https://sourceforge.net/projects/virtualgl/files/2.6.5/virtualgl_2.6.5_amd64.deb/download -O virtualgl_2.6.5_amd64.deb
sudo dpkg -i virtualgl_2.6.5_amd64.deb
service lightdm stop
sudo /opt/VirtualGL/bin/vglserver_config
sudo reboot
```

## Install TurboVNC on Ubuntu

```wget wget https://sourceforge.net/projects/turbovnc/files/2.2.6/turbovnc_2.2.6_amd64.deb/download -O turbovnc_2.2.6_amd64.deb
sudo dpkg -i  turbovnc_2.2.6_amd64.deb
```

## Start TurboVNC

```
/opt/TurboVNC/bin/vncserver
# Following depends on what previous command returns. Should be :1 when starting
DISPLAY=:1
```

## Configure WiFi

\# Rename network (not permanent). This is needed, apparently, because "wlp0s20f3" is too long a name

```sudo ip link set down wlp0s20f3 && sudo ip link set wlp0s20f3 name wlan0 && sudo ip link set up wlan0```

\# Fix things to access my household network, HOUSEHOLD

```sudo su
wpa_passphrase HOUSEHOLD >> /etc/wpa_supplicant.conf
<passphrase>
```

```
sudo su
cat > /etc/network/interfaces <<EOF
auto wlan0
iface wlan0 inet dhcp
wpa-driver nl80211
wpa-conf /etc/wpa_supplicant.conf
EOF
```

\# Update wpa_supplicant.conf
  
```sudo wpa_supplicant -c /etc/wpa_supplicant.conf -Dnl80211 -iwlan0
# Note: Must terminate with ^C
```

\# Get IP address for new network
  
```
sudo apt install ifupdown
sudo ifup wlan0
```
  
\# Note the IP address that it creates
