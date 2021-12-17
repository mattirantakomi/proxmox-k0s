variable "hcloud_token" {}
variable "hcloud_master_details" {}
variable "domain" {}

provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_server" "master" {
  name        = "master.${var.domain}"
  image       = "ubuntu-20.04"
  server_type = "cx11"
  location    = "hel1"
  ssh_keys    = [ "key1", "key2" ] # SSH key names on Hetzner Cloud console
  user_data = "${file("user_data.yml")}"
}

data "hcloud_server" "master" {
  name = "${hcloud_server.master.name}"
}

locals {
  hcloud_master_details = <<-EOT
  ansible_host: ${data.hcloud_server.master.ipv4_address}
  # timestamp ${timestamp()}
  EOT
}

resource "local_file" "hcloud_master_details" {
  filename = var.hcloud_master_details
  content  = local.hcloud_master_details
}