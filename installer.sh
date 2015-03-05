#!/bin/bash -e
echo "Installing / Updating mass tool"
cd /tmp
git clone https://github.com/lukaszraczylo/mass.git
cp mass/installer.sh /usr/local/bin/mass-updater
cp mass/mass /usr/local/bin/mass
chmod +x /usr/local/bin/mass*
rm -fr /tmp/mass