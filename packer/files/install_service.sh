#!/bin/bash
set -e

touch /etc/systemd/system/puma.service
chmod 664 /etc/systemd/system/puma.service

cat <<EOF > /etc/systemd/system/puma.service
[Unit]
Description=Puma Reddit custom service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/appuser/reddit
ExecStart=/bin/bash -lc 'bundle exec puma -b tcp://0.0.0.0:9292'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable puma.service
