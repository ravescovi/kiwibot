# D) Install Virtual GL on Ubuntu
# [See https://gist.github.com/cyberang3l/422a77a47bdc15a0824d5cca47e64ba2]
wget https://sourceforge.net/projects/virtualgl/files/2.6.5/virtualgl_2.6.5_amd64.deb/download -O virtualgl_2.6.5_amd64.deb
sudo dpkg -i virtualgl_2.6.5_amd64.deb
service lightdm stop
sudo /opt/VirtualGL/bin/vglserver_config
sudo reboot
# E) Install TurboVNC on Ubuntu
wget  https://sourceforge.net/projects/turbovnc/files/2.2.6/turbovnc_2.2.6_amd64.deb/download -O turbovnc_2.2.6_amd64.deb
sudo dpkg -i turbovnc_2.2.6_amd64.deb
# F) Start TurboVNC
/opt/TurboVNC/bin/vncserver


   # [See https://gist.github.com/cyberang3l/422a77a47bdc15a0824d5cca47e64ba2]
   wget https://sourceforge.net/projects/virtualgl/files/2.6.5/virtualgl_2.6.5_amd64.deb/download -O virtualgl_2.6.5_amd64.deb
   sudo dpkg -i virtualgl_2.6.5_amd64.deb
   service lightdm stop
   sudo /opt/VirtualGL/bin/vglserver_config
   sudo reboot

E) Install TurboVNC on Ubuntu

   wget wget https://sourceforge.net/projects/turbovnc/files/2.2.6/turbovnc_2.2.6_amd64.deb/download -O turbovnc_2.2.6_amd64.deb
   sudo dpkg -i  turbovnc_2.2.6_amd64.deb

