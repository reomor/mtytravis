#!/bin/sh
set -e
./dynamic-inventory/gce.py --list | sed 's/reddit-db/db/g; s/reddit-app/app/g'
