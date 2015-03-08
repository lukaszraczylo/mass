#!/bin/bash -e
echo "Installing / Updating mass tool"
LIB_DIRECTORY=/usr/local/lib/mass
BIN_DIRECTORY=/usr/local/bin
rm -f $BIN_DIRECTORY/mass
if [ ! -d "$LIB_DIRECTORY" ]; then
  git clone https://github.com/lukaszraczylo/mass.git $LIB_DIRECTORY
else
  cd $LIB_DIRECTORY
  git pull --rebase
fi
cd $LIB_DIRECTORY
bundle install
cp installer.sh $BIN_DIRECTORY/mass-updater && chmod +x $BIN_DIRECTORY/mass-updater
ln -s $LIB_DIRECTORY/mass $BIN_DIRECTORY/mass