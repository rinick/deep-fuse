#!/usr/bin/env bash

# 安装Dart，( 因为官方下载国内用不了，我把安装包复制在github上 )
wget https://github.com/rinick/dart_sdk/releases/download/1.19.1/dart_1.19.1-1_amd64.deb
sudo dpkg -i --force-all dart_1.19.1-1_amd64.deb

# 安装torch
curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
git clone https://github.com/torch/distro.git ~/torch --recursive
cd torch
sed 's/read input/input="yes"/' < install.sh | bash
./install/bin/torch-activate
cd ..

# 安装caffee加载器
luarocks install loadcaffe

# 安装Neural Style Server
git clone https://github.com/rinick/neural-style-server.git --recursive
cd neural-style-server/neural-style
sh ./models/download_models.sh

cd ..

/usr/lib/dart/bin/pub get
/usr/lib/dart/bin/pub build
