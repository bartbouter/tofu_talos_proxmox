# talos_proxmox_deployment
talos cluster deployment on proxmox with opentofu / terraform

## Linux / WSL preparations

Add Docker's official GPG key:
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```
Add the repository to Apt sources:
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
Create docker group and add user
```bash
sudo groupadd docker
sudo usermod -aG docker ${USER}
```
Install Docker
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```

Install qemu-utils
```bash
sudo apt install qemu-utils -y
```

## Create talos disk image
Create the raw disk image
```bash
talos/create_disk_image.sh
```

## opentofu
```bash
tofu init
```

```bash
tofu plan -out=talosplan -var="virtual_environment_endpoint=https://10.0.0.250:8006" -var="virtual_environment_username=root@pam" -var="virtual_environment_password=password" -var="encryption_passphrase=encryption-passphrase" -var="talos_cluster_endpoint=https://cluster.local:6443"
```

```bash
tofu apply talosplan
```

## talosctl config

Export the talosconfig to a file
```bash
tofu output -raw talosconfig > talosconfig.yaml
```

Use the talosctl config
```
talosctl --talosconfig talosconfig.yaml -n <controlplane ip> get members
```

Or use bin/export_config.sh

## kubeconfig

Export the kubeconfig to a file
```bash
tofu output -raw kubeconfig > kubeconfig.yaml
```

Test the kubeconfig
```
kubectl --kubeconfig kubeconfig.yaml cluster-info
```

Or use bin/export_config.sh
