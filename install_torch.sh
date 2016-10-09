#!/usr/bin/env bash

curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
git clone https://github.com/torch/distro.git ~/torch --recursive
cd torch
sed 's/read input/input="yes"/' < install.sh | bash