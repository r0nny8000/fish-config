#!/bin/bash

pwd=$(pwd)

echo "origin: $pwd"

echo -n 'Creating symbolic links...'

cd ~
cd .config

mv fish fish.legacy

ln -s $pwd fish

echo ' done.'
ls -la

cd $pwd
