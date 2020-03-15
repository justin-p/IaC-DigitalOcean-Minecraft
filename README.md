# IaC Minecraft Server on Digital Ocean

Based of https://github.com/vyrtualsynthese/Digital-Ocean-OnDemand-Minecraft-Server

Guide cloned from https://medium.com/@vyrtualsynthese/on-demand-minecraft-server-with-terraform-and-digital-ocean-3afcc8a5fe90 

## Prerequisite

- A Digital Ocean account with few credits to rent your droplet.
- Digital Ocean CLI to get some informations from DO API.
- OpenSSH client to generate your SSH key to be used to identify to your Droplets. I think it is available out of the box for all windows and mac. For linux refere o your favorit package manager.
- A tool to tar gz. Native on almost all linux distro and mac. For windows I prefer 7zip.
- Java 8.
- MCrcon to inject commands on your running Minecraft Server.
- Terraform.

## Prepare the project for production

1. Download your Minecraft Server from minecraft official website https://www.minecraft.net/en-us/download/server/

```
cd Digital-Ocean-OnDemand-Minecraft-Server
wget [the server link taken from minecraft website]
```

2. Create an ‘minecraft-server’ folder and move your server files into the uploadFolder

```
mkdir uploadFolder/minecraft-server
mv server.jar uploadFolder/minecraft-server
``` 

3. If it is a new server Run it one time to generate server configuration files

```
java -Xmx1024M -Xms1024M -jar uploadFolder/minecraft-server/server.jar nogui
```

4. The server should start and stop by himself then you could edit eula.txt.
Set eula to true. It should be like this.

```
eula=true
```

5. Next step is to setup your server.properties file. Feel free to configure your server as you want but you need to make sure enable-rcon is set to true and you have an rcon.password set up.

```
rcon.password=foo
enable-rcon=true
```

6. Make sure your configuration is ok by running the server on last time and connecting to it. Then shut it down and you are all set. Last Step is to compress the server file in tar.gz format.

```
cd uploadFolder
tar czvf minecraft-server.tar.gz minecraft-server
```

## SSH Keys

You need an ssh key to help terraform inject commands over SSH into your droplet instance after it is activated.
First it is better to generate a dedicated SSH key for your Terraform scripts.

```
ssh-keygen
```

We will name that new key mc_rsa

```
Generating public/private rsa key pair.
Enter file in which to save the key (/your_home/.ssh/id_rsa): mc_rsa
```

## Connect doctl with your Digital Ocean account

Run `doctl auth init` command.
Go to your Digital Ocean accout under API and click Generate New Token.
Then copy your token into the terminal.
Now your doctl have access to your account information.

## Configure your terraform script

Inside the project copy the environment variable file to edit

```
cp terraform.tfvars.dist terraform.tfvars
```

`do_token` past your previous generated Digital Ocean API Token
`pub_key` input the path to your rsa public key in our exemple : "~/.ssh/mc_rsa.pub"
`pvt_key` input the path to your rsa private key in our exemple : "~/.ssh/mc_rsa"
`rcon_pwd` your previously setup rcon password for your minecraft server
`man_ip` input external ip for management here (["1.2.3.4/32"])
`play_ip` input external ip from players ip here (["1.2.3.4/32","3.4.5.6/32"]). P.S. if you want the whole internet to connect type ["0.0.0.0/0","::/0"]

For the last two field you need to call Digital Ocean’s api to get droplets informations
`doctl compute size list --output json` will give your informations about available droplets. When you have chose your droplet size take note of your droplet slug and region and input it in your terraform.tfvars file.
My go to droplet is the `s-1vcpu-1gb` strong enough to play with few friends.

Don't forget to update the `docker-compose.yml` file in the upload folder to reflect your chose of droplet.

## Run your Minecraft Server

Now the hard part is done time to run your Minecraft Server with some simple commands.
Make sure you are in your Terraform project folder then

```
terraform init
```

```
terraform plan
```

```
terraform apply
```

Then after reviewing your configuration juste write

```
yes
```

Once finished terraform will print your server IP in your terminal. You may have to wait few more minutes untils the Minecraft Server finished starting.
To connect to the console of your server your can use mcrcon as following

```
mcrcon -H <Your-Server-ip> -p <your-rcon-password>
```

## Destroy your Minecraft Server

From inside your Terraform project former type

```
terraform destroy
```

Then after reviewing your configuration

```
yes
```

Your minecraft server will be gracefully shut down then compressed the downloaded in your local Minecraft Server folder then shutdown.
