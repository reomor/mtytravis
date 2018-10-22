#!/bin/bash
set -e

gcloud compute instances create reddit-full-instance \
 --image-family reddit-full \
 --image-project steadfast-slate-219116

gcloud compute instances add-tags reddit-full-instance \
 --tags puma-server
