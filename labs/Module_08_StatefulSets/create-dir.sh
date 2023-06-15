!#/bin/bash
DIRNAME="vol1"
mkdir -p /mnt/$DIRNAME 
# chcon -Rt svirt_sandbox_file_t /mnt/$DIRNAME         #Only required if SELinux is enabled
chmod 777 /mnt/$DIRNAME