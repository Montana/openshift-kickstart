#!/bin/sh

set -e

if [ $# -lt 1 ]
then
  printf 'Usage: %s vm_name [arg1 [arg2 [...]]]\n' "$0"
  printf 'Example:\n'
  printf '%s my_new_broker_and_node install_components=broker,node,activemq,datastore named_ip_addr=10.0.0.1' "$0"
  exit 1
fi

NAME="$1"; shift
DISK=/opt/"$NAME"

CMDLINE='ks=http://file.rdu.redhat.com/~mmasters/openshift.ks'
for ARG
do
  CMDLINE="$CMDLINE $ARG"
done

set -x

qemu-img create "$DISK" 30G -f raw && mkfs.ext4 -F "$DISK"

virt-install --name="$NAME" --ram=2048 --vcpus=2 --hvm --disk "$DISK" \
  --location http://download.devel.redhat.com/released/RHEL-6/6.3/Server/x86_64/os/ \
  -x "$CMDLINE" \
  --connect qemu:///system --network bridge=br0 --graphics vnc -d --wait=-1 \
  --autostart
