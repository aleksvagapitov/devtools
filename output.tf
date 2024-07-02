# Jump Server IP
output "jump-server-ip" {
 value = [hcloud_server.jump-server.ipv4_address]
}