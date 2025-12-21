/etc/hosts
node-1-external 10.0.1.1
node-2-external 10.0.1.2
node-3-external 10.0.1.3

(internal is for MinIO only!)
on node-1: 
node-2-internal 10.0.20.2
node-3-internal 10.0.21.2

on node-2: 
node-1-internal 10.0.20.1
node-3-internal 10.0.23.2

on node-3: 
node-1-internal 10.0.21.1
node-2-internal 10.0.22.1

1-2
10.0.20.1 (1)
10.0.20.2 (2)

1-3
10.0.21.1 (1)
10.0.21.2 (3)

2-3
10.0.22.1 (2)
10.0.22.2 (3)




node-1
SFP0 10.0.20.1 (1-2)
SFP1 10.0.21.1 (1-3)

node-2
SFP0 10.0.20.2(2-1)
SFP1 10.0.22.1 (2-3)

node-3
SFP0 10.0.21.2 (3-1)
SFP1 10.0.22.2 (3-2)
