# reomor_infra
reomor Infra repository
# connect to private host through bastion via one console command

ssh reomor@10.132.0.3 -o "proxycommand ssh -W %h:%p reomor@35.210.242.212"

# connect to private via alias
# e.g. ssh someinternalhost
# add config to ~/.ssh/config

 Host bastion
    User reomor
    Hostname 35.210.242.212

 Host someinternalhost
    User reomor
    Hostname 10.132.0.3
    ProxyCommand ssh -q -W %h:%p bastion

