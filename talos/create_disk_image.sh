#!/bin/bash
if [ -d "$PWD/_out" ]; then
    rm -rf "$PWD/_out"
fi
docker run --rm -i -v $PWD/_out/tmp:/secureboot:ro -v $PWD/_out:/out -v /dev:/dev --privileged "ghcr.io/siderolabs/imager:v1.7.5" - < talos.yaml
if [ -e "$PWD/_out/nocloud-amd64.raw" ]; then
    qemu-img convert -O qcow2 $PWD/_out/nocloud-amd64.raw $PWD/_out/talos-nocloud.qcow2
    qemu-img info $PWD/_out/talos-nocloud.qcow2
else
    echo "Error: $PWD/_out/nocloud-amd64.raw does not exist."
fi
