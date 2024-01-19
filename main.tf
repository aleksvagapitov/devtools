# Create an ssh-key
resource "hcloud_ssh_key" "default" {
  name       = "My SSH KEY"
  public_key = file("~/.ssh/devtools-kube.pub")
}

# Create the jump-server ssh-key
resource "hcloud_ssh_key" "jump_server" {
  name       = "JUMP SERVER SSH KEY"
  public_key = file("~/.ssh/jump-server.pub")
}

# Create the jump-server
resource "hcloud_server" "jump-server" {
  name        = "jump-server"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  datacenter  = "hel1-dc2"
  ssh_keys    = ["My SSH KEY"]
  public_net  {
    ipv4_enabled = true
    ipv6_enabled = false
  }


  network {
    network_id = hcloud_network.kubernetes-node-network.id
    ip         = "172.16.0.100"
  }

  depends_on = [
    hcloud_network_subnet.kubernetes-node-subnet
  ]

  provisioner "file" {
    source      = "~/.ssh/jump-server"
    destination = ".ssh/jump-server"

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      private_key = file("~/.ssh/devtools-kube")
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "remote-exec" {
    script = "scripts/remote-config.sh"

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      private_key = file("~/.ssh/devtools-kube")
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "file" {
    source      = "server"
    destination = ".server/"

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      private_key = file("~/.ssh/devtools-kube")
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "file" {
    source      = "scripts"
    destination = ".scripts/"

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      private_key = file("~/.ssh/devtools-kube")
      user        = "root"
      timeout     = "2m"
    }
  }
}

# Create the kubernetes nodes
resource "hcloud_server" "kube-node" {
  count       = 1
  name        = "kube-node-${count.index + 1}"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  datacenter  = "hel1-dc2"
  ssh_keys    = ["My SSH KEY", "JUMP SERVER SSH KEY"]
  public_net  {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.kubernetes-node-network.id
    ip         = "172.16.0.10${count.index + 1}"
  }

  depends_on = [
    hcloud_network_subnet.kubernetes-node-subnet
  ]
}

# Create the node network
resource "hcloud_network" "kubernetes-node-network" {
  name     = "kubernetes-node-network"
  ip_range = "172.16.0.0/24"
}


# Create the node subnet
resource "hcloud_network_subnet" "kubernetes-node-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.kubernetes-node-network.id
  network_zone = "eu-central"
  ip_range     = "172.16.0.0/24"
}

resource "local_file" "hosts_cfg" {
    content = templatefile("server/inventory.tmpl", 
        {
            ubuntu_workers = hcloud_server.kube-node
        }
    )
    filename = "server/inventory"
}
