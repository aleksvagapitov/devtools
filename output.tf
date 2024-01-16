# Jump Server IP
output "jump-server-ip" {
 value = [hcloud_server.jump-server.ipv4_address]
}

# Node IPs
# output "kube-node-1-ip" {
#  value = [for node in hcloud_server.kube-node[0].network: node.ip]
# }
