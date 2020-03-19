variable "do_token" {
  description = "Your Digital Ocean Api token generated from here https://cloud.digitalocean.com/account/api/tokens"
  default = ""
}

variable "do_tag" {
  description = "Tag added to the DigitalOcean Droplet"  
  default = "mc-server"
}

variable "do_name" {
  description = "Name of the new to the DigitalOcean Droplet"
  default = "mc-server"
}

variable "do_description" {
  description = "Description of the new to the DigitalOcean Droplet"
  default = "Minecraft server."
}

variable "do_ssh_key" {
  description = "Name of the SSH public key added to DigitalOcean"  
  default = "mc-server-SSH-Key"
}

variable "pub_key" {
  description = "Path to your generated public key. Used for SSH/SCP authentication."  
  default = ""
}

variable "pvt_key" {
  description = "Path to your generated private key. Used for SSH/SCP authentication."  
  default = ""
}

variable "this_folder" {
  description = "Path to this repository"  
  default = ""
}

variable "rcon_pwd" {
  description = "The rcon password of your server"  
  default = ""
}

variable "region" {
  description = "Region to create droplet in"  
  default = "ams3"
}

variable "size" {
  description = "Droplet Size"  
  default = "s-2vcpu-4gb"
}

variable "man_ip" {
  description = "Opens SSH for listed IPs"  
  default = ["0.0.0.0/0","::/0"]
}

variable "play_ip" {
  description = "Player IPs"  
  default = ["0.0.0.0/0","::/0"]
}

variable "skipmessage" {
  description = "Enable or Disable discord integration"  
  default = "true"
}

variable "webhook" {
  description = "Webhook url for discord bot"
  default = ""
}
