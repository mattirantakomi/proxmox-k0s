provider "cloudflare" {
  email   = var.cloudflare_email
  api_token = var.cloudflare_api_token
}

variable "cloudflare_email" {}
variable "cloudflare_api_token" {}
variable "domain" {}

data "cloudflare_zone" "domain_tld" {
  name = var.domain
}

resource "cloudflare_record" "master" {
  zone_id = data.cloudflare_zone.domain_tld.id
  name    = "master"
  value   = "${data.hcloud_server.domain_tld.ipv4_address}"
  type    = "A"
  proxied = false
}