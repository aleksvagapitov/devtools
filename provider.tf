provider "hcloud" {
  token = "${var.HCLOUD_API_TOKEN}"
}

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.44.1"
    }
  }
}
