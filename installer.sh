#!/bin/bash -e
echo "Installing / Updating mass tool"
LIB_DIRECTORY=/usr/local/lib/mass
BIN_DIRECTORY=/usr/local/bin
rm -f $BIN_DIRECTORY/mass
if [ ! -d "$LIB_DIRECTORY" ]; then
  git clone -b master https://github.com/lukaszraczylo/mass.git $LIB_DIRECTORY
else
  cd $LIB_DIRECTORY
  git pull --rebase
fi
git clone git@github.com:mattneub/appscript.git /tmp/appscript
cd /tmp/appscript/rb-appscript/trunk
ruby extconf.rb && make && make install
gem build rb-appscript.gemspec
gem install rb-appscript-0.6.1.gem
cd $LIB_DIRECTORY
bundle install
cp installer.sh $BIN_DIRECTORY/mass-updater && chmod +x $BIN_DIRECTORY/mass-updater
ln -s $LIB_DIRECTORY/mass $BIN_DIRECTORY/mass