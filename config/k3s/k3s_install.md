start command:

curl -sfL https://get.k3s.io | sudo sh -s - server \
  --flannel-backend=host-gw



# --- Cluster ---
cluster-init: false # true for node-1
server: https://10.0.1.1:6443
token-file: /mnt/raid/k3s/server/node-token

# --- Identity ---
node-ip: 10.0.1.2
advertise-address: 10.0.1.2

# --- Storage ---
data-dir: /mnt/raid/k3s

# --- Networking ---
flannel-backend: host-gw
flannel-iface: enp3s0

# --- SAN ---
tls-san:
  - 10.0.1.1
  - 10.0.1.2
  - 10.0.1.3

