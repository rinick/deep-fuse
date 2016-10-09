#!/usr/bin/env bash

# 安装 dart
curl -O -J -L https://github.com/rinick/sdk/releases/download/1.20.0-dev.10.1/dart_1.20.0-dev.10.1-1_amd64.deb
sudo dpkg -i --force-all dart_1.20.0-dev.10.1-1_amd64.deb

# 安装caffee加载器
luarocks install loadcaffe

# 安装Neural Style Server
git clone https://github.com/rinick/neural-style-server.git --recursive
cd neural-style-server/neural-style
sh ./models/download_models.sh

cd ..

/usr/lib/dart/bin/pub get -v
/usr/lib/dart/bin/pub build
