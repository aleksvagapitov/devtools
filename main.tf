terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.44.1"
    }
  }
}

variable "hcloud_api_token" {}

resource "hcloud_ssh_key" "devtools" {
  name       = "devtools_key"
  public_key = file("~/.ssh/devtools.pub")
}

provider "hcloud" {
  token = var.hcloud_api_token
}

# Create a web server
resource "hcloud_server" "devtools" {
  image       = "ubuntu-22.04"
  name        = "devtools"
  location    = "ash"
  server_type = "cpx11"
  ssh_keys    = [hcloud_ssh_key.devtools.id]

  provisioner "remote-exec" {
    script = "scripts/remote-config.sh"

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      private_key = file("~/.ssh/devtools")
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
      private_key = file("~/.ssh/devtools")
      user        = "user"
      timeout     = "2m"
    }
  }

  provisioner "file" {
    source      = "scripts"
    destination = ".scripts/"

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      private_key = file("~/.ssh/devtools")
      user        = "user"
      timeout     = "2m"
    }
  }

  provisioner "file" {
    source      = "~/.ssh/github"
    destination = ".ssh/github"

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      private_key = file("~/.ssh/devtools")
      user        = "user"
      timeout     = "2m"
    }
  }
}

output "public_ip" {
  value = "ssh -i ~/.ssh/devtools user@${hcloud_server.devtools.ipv4_address}"
}

output "copy_ssh_file" {
  value = "scp -i ~/.ssh/devtools ~/.ssh/github user@${hcloud_server.devtools.ipv4_address}:/home/user/.ssh/"
}

output "copy_vpn_file" {
  value = "scp -i ~/.ssh/devtools user@${hcloud_server.devtools.ipv4_address}:client.ovpn ~/Desktop"
}
