#!/bin/bash
sudo apt-get update
sudo apt-get install -y curl python3
sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
sudo python3 -m pip install ansible