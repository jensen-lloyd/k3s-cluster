internal connections between nodes
all subnets /30

node-1
SFP0 10.0.20.1 (1-2)
SFP1 10.0.21.1 (1-3)

node-2
SFP0 10.0.20.2(2-1)
SFP1 10.0.22.1 (2-3)

node-3
SFP0 10.0.21.2 (3-1)
SFP1 10.0.22.2 (3-2)



each node also gets a dummy interface
abstract0
which will then have static routes assigned to it to allow
for node to node communication over a single set of IPs in 
the same subnet
10.1.0.0/24

node-1 10.1.0.1
node-2 10.1.0.2
node-3 10.1.0.3


VIP with kube-vip
10.0.1.100
