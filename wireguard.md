Wireguard config to create virtual mesh over 10G SFP links for Flannel to use as inter-node k3s comms



wg0
10.1.0.0/24



node-1
/etc/wireguard/wg0.conf

[Interface]
Address = 10.1.0.1/24
ListenPort = 51820
PrivateKey = CIO1uRZf3oYkGQsXl5mZz35RMTc2yqSD5qrnP6VkKXM=

[Peer]
PublicKey = gp8BStjuHSY5nE0YrBZVXX+4sydMRrkzr8z8WCifenw=
AllowedIPs = 10.1.0.2/32
Endpoint = node-2-internal:51820
PersistentKeepalive = 25

[Peer]
PublicKey = yvAPkHFOht3wS8fiGTAxW430PRltDPOAEtFV0Cvs9TA=
AllowedIPs = 10.1.0.3/32
Endpoint = node-3-internal:51820
PersistentKeepalive = 25



node-2
/etc/wireguard/wg0.conf

[Interface]
Address = 10.1.0.2/24
ListenPort = 51820
PrivateKey = yCwt6B/QbNfLuUR0aeOYjqjimAn4EEN8XcTXKuR7A3M=

[Peer]
PublicKey = OgLCcEAZ0xiueOtZmEu/qEWX1OKvLjuKATJVT6hP3gI=
AllowedIPs = 10.1.0.1/32
Endpoint = node-1-internal:51820
PersistentKeepalive = 25

[Peer]
PublicKey = yvAPkHFOht3wS8fiGTAxW430PRltDPOAEtFV0Cvs9TA=
AllowedIPs = 10.1.0.3/32
Endpoint = node-3-internal:51820
PersistentKeepalive = 25



node-3
/etc/wireguard/wg0.conf

[Interface]
Address = 10.1.0.3/24
ListenPort = 51820
PrivateKey = 2PNr/boEdht0AJXj8YMYKScz1jg4pUAbNGKwzBBqd1s=

[Peer]
PublicKey = OgLCcEAZ0xiueOtZmEu/qEWX1OKvLjuKATJVT6hP3gI=
AllowedIPs = 10.1.0.1/32
Endpoint = node-1-internal:51820
PersistentKeepalive = 25

[Peer]
PublicKey = gp8BStjuHSY5nE0YrBZVXX+4sydMRrkzr8z8WCifenw=
AllowedIPs = 10.1.0.2/32
Endpoint = node-2-internal:51820
PersistentKeepalive = 25
