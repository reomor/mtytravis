#!/bin/bash
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
PUMA_PORT=$(ps aux | grep puma | grep -v grep | awk '{print $13}' | cut -d')' -f1 | cut -d':' -f2)
echo $PUMA_PORT
