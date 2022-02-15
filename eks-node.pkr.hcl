packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

source "digitalocean" "debian" {
  image        = "debian-11-x64"
  region       = "lon1"
  size         = "s-1vcpu-1gb"
  ssh_username = "root"
}

build {
    sources = ["sources.digitalocean.debian"]

    provisioner "shell" {
        scripts = [
            "./scripts/provision-ansible.sh"
        ]
    }

    provisioner "ansible-local" {
      playbook_file   = "./playbooks/playbook.yml"
      group_vars      = "./playbooks/group_vars"
      role_paths      = [
        "./playbooks/roles/base"
      ]
    }
}