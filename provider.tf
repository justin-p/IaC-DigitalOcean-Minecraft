variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "rcon_pwd" {}
variable "region" {}
variable "size" {}
variable "man_ip" {}
variable "play_ip" {}

provider "digitalocean" {
  token = var.do_token
}
