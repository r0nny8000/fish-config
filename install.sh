#!/bin/bash

pwd=$(pwd)

echo "origin: $pwd"

echo -n 'Creating symbolic links...'

cd ~
mkdir -p .config
cd .config

mv fish fish.legacy

ln -s $pwd fish

echo ' done.'
ls -la

cd $pwd

echo "please execute follwing commands with sudo"
echo "fish is installed here: "

which fish

echo "echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells"
echo "chsh -s /opt/homebrew/bin/fish"

