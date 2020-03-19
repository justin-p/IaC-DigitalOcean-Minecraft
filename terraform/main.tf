provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "mc-server-SSH-Key"
  public_key = file(var.pub_key)
}

resource "digitalocean_tag" "mc-server" {
  name = var.do_tag
}

resource "digitalocean_project" "mc-server" {
  name        = var.do_name
  description = var.do_description
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
    source      = "${var.this_folder}/uploadFolder/"
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
      "cd uploadFolder",
      "tar -xvzf minecraft-server.tar.gz",
      "cd minecraft-server",
      "docker-compose up -d",
      "dig +short myip.opendns.com @resolver1.opendns.com"
    ]
  }

  provisioner "local-exec" {
    command = "python3 ${var.this_folder}/discordbot/bot.py -u ${var.webhook} -c 'Minecraft server ${var.do_name} has just been created, may take up to 2 minutes for everything to load. IP: ${digitalocean_droplet.mc-server.ipv4_address}' --skipmessage ${var.skipmessage}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "python3 ${var.this_folder}/discordbot/bot.py -u ${var.webhook} -c 'The Minecraft server ${var.do_name} at IP ${digitalocean_droplet.mc-server.ipv4_address} is shutting down.' --skipmessage ${var.skipmessage}"
  }   

  provisioner "remote-exec" {
    when    = destroy
    inline = [
      "cd uploadFolder",
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
    command = "scp -i ${var.pvt_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${digitalocean_droplet.mc-server.ipv4_address}:uploadFolder/minecraft-server.tar.gz ${var.this_folder}/uploadFolder"
  }
}
