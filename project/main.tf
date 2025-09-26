terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.0"
    }
  }
}

provider "hcloud" {}

# Look up the SSH key you added to your Hetzner Cloud project
data "hcloud_ssh_key" "default" {
  # IMPORTANT: Change this to the name you gave your key in the Hetzner Cloud console
  name = "your-key-name-in-hetzner"
}

resource "hcloud_server" "web_server" {
  name        = "webserver-01"
  image       = "ubuntu-22.04"
  server_type = "cpx11"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.default.id]

  # THIS IS THE CRITICAL PART FOR ANSIBLE
  # We are "tagging" this server so the Ansible plugin can find it.
  labels = {
    "ansible_group" = "webservers"
  }
}

output "server_ip" {
  value = hcloud_server.web_server.ipv4_address
}

# Generates an Ansible inventory file from a template
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    webservers = [hcloud_server.web_server]
  })
  filename = "${path.module}/inventory/hosts"
}
