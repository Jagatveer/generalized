Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

# for C5, C5d, M5, and i3.metal instances which expose EBS volumes as NVMe block devices.
cloud-init-per once Wipe-NVMeInstanceStore wipefs -a /dev/nvme2n1
cloud-init-per once ConfigureDockerStorage sed -i 's/xvdcz/nvme2n1/g' /etc/sysconfig/docker-storage-setup

# For changing dm.basesize
cloud-init-per once docker_options echo 'OPTIONS="$${OPTIONS} --storage-opt dm.basesize=${storage}G"' >> /etc/sysconfig/docker

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
# Set any ECS agent configuration options
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config


--==BOUNDARY==--
