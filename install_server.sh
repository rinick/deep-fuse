#!/usr/bin/env bash

# install dart

curl -O -J -L https://github.com/rinick/sdk/releases/download/1.20.0-dev.10.1/dart_1.20.0-dev.10.1-1_amd64.deb
sudo dpkg -i --force-all dart_1.20.0-dev.10.1-1_amd64.deb

# a work around for the dart pub issue in windows 10 linux subsystem

mkdir -p ~/.pub-cache/hosted/pub.dartlang.org
mkdir ~/.pub-cache/hosted/pub.dartlang.org/http_server-0.9.6
mkdir ~/.pub-cache/hosted/pub.dartlang.org/mime-0.9.3
mkdir ~/.pub-cache/hosted/pub.dartlang.org/path-1.3.9
mkdir ~/.pub-cache/hosted/pub.dartlang.org/browser-0.10.0+2

curl -O -J -L https://pub.dartlang.org/packages/http_server/versions/0.9.6.tar.gz
curl -O -J -L https://pub.dartlang.org/packages/mime/versions/0.9.3.tar.gz
curl -O -J -L https://pub.dartlang.org/packages/path/versions/1.3.9.tar.gz
curl -O -J -L https://pub.dartlang.org/packages/browser/versions/0.10.0%2B2.tar.gz

tar -xvf 0.9.6.tar.gz -C ~/.pub-cache/hosted/pub.dartlang.org/http_server-0.9.6
tar -xvf 0.9.3.tar.gz -C ~/.pub-cache/hosted/pub.dartlang.org/mime-0.9.3
tar -xvf 1.3.9.tar.gz -C ~/.pub-cache/hosted/pub.dartlang.org/path-1.3.9
tar -xvf 0.10.0%2B2.tar.gz -C ~/.pub-cache/hosted/pub.dartlang.org/browser-0.10.0+2

rm dart_1.20.0-dev.10.1-1_amd64.deb
rm 0.9.6.tar.gz
rm 0.9.3.tar.gz
rm 1.3.9.tar.gz
rm 0.10.0%2B2.tar.gz



# install loadcaffee

luarocks install loadcaffe

# install Neural Style Server

git clone https://github.com/rinick/neural-style-server.git --recursive
cd neural-style-server/neural-style
sh ./models/download_models.sh

cd ..

# compile dart code

/usr/lib/dart/bin/pub get --offline

/usr/lib/dart/bin/pub build

