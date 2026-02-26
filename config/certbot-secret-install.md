sudo certbot certonly --config certbot-wildcard.ini


kubectl create secret tls wildcard-colins-io-tls \
  --cert=/etc/letsencrypt/live/colins.io/fullchain.pem \
  --key=/etc/letsencrypt/live/colins.io/privkey.pem \
  -n default


kubectl get secret wildcard-colins-io-tls -n default

