#cloud-config
chpasswd:
  list: |
    root:my-lovely-password
    centos:my-lovely-password
  expire: False
