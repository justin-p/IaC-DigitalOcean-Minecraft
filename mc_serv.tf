resource "digitalocean_ssh_key" "default" {
  name       = "mc-server-SSH-Key"
  public_key = file(var.pub_key)
}

resource "digitalocean_tag" "mc-server"{
  name = "mc-server"
}

resource "digitalocean_project" "mc-server" {
  name        = "mc-server"
  description = "Minecraft server."
  purpose     = "Other"
  resources   = [digitalocean_droplet.mc-server.urn]
}

resource "digitalocean_firewall" "mc-server" {
  name = "mc-server"
  tags = ["mc-server"]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.man_ip 
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "2375-2376"
    source_addresses = var.man_ip 
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "25565"
    source_addresses = var.play_ip
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "19132-19133"
    source_addresses = var.play_ip
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "25565"
    source_addresses = var.play_ip
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }  
}

resource "digitalocean_droplet" "mc-server" {
  image = "docker-18-04"
  name = "mc-server"
  tags = ["mc-server"]
  ipv6 = false
  region = var.region
  size = var.size
  private_networking = true
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  provisioner "file" {
    source      = "uploadFolder/"
    destination = "."
  }
  connection {
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
    host = digitalocean_droplet.mc-server.ipv4_address
  }
  provisioner "remote-exec" {
    inline = [
      "wget https://github.com/Tiiffi/mcrcon/releases/download/v0.0.5/mcrcon-0.0.5-linux-x86-64.tar.gz",
      "tar -xvzf mcrcon-0.0.5-linux-x86-64.tar.gz",
      "mv mcrcon /usr/local/bin",
      "tar -xvzf minecraft-server.tar.gz",
      "cd minecraft-server",
      "docker-compose up -d",
      "dig +short myip.opendns.com @resolver1.opendns.com"
    ]
  }
  provisioner "remote-exec" {
    when    = destroy
    inline = [
      "echo sleeping",
      "sleep 15",
      "mcrcon -H localhost -p ${var.rcon_pwd} save-all",
      "sleep 15", // TODO: Investigate the rcon solution to get status from mc server
      "mcrcon -H localhost -p ${var.rcon_pwd} stop",
      "sleep 15",
      "docker-compose down",
      "tar -cvzf minecraft-server.tar.gz minecraft-server",
    ]
  }
  provisioner "local-exec" {
    when    = destroy
    command = "scp -i ${var.pvt_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${digitalocean_droplet.mc-server.ipv4_address}:minecraft-server.tar.gz uploadFolder"
  }
}