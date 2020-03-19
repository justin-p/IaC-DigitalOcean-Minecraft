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
- Python3 and pip3
  - Install the requirements.txt in the discordbot folder (pip3 install -r requirements.txt)

## Prepare the project for production

1. Download your Minecraft Server from minecraft official website https://www.minecraft.net/en-us/download/server/

```bash
cd Digital-Ocean-OnDemand-Minecraft-Server
wget [the server link taken from minecraft website]
```

2. Create an ‘minecraft-server’ folder and move your server files into the uploadFolder

```bash
mkdir uploadFolder/minecraft-server
mv server.jar uploadFolder/minecraft-server
```

3. If it is a new server run it one time to generate server configuration files

```bash
java -Xmx1024M -Xms1024M -jar uploadFolder/minecraft-server/server.jar nogui
```

4. The server should start and stop by himself then you could edit eula.txt.
Set eula to true. It should be like this.

```bash
eula=true
```

5. Next step is to setup your server.properties file. Feel free to configure your server as you want but you need to make sure enable-rcon is set to true and you have an rcon.password set up.

```bash
rcon.password=foo
enable-rcon=true
```

6. Make sure your configuration is ok by running the server on last time and connecting to it. Then shut it down and you are all set. Last Step is to compress the server file in tar.gz format.

```bash
cd uploadFolder
tar czvf minecraft-server.tar.gz minecraft-server
```

## SSH Keys

You need an ssh key to help terraform inject commands over SSH into your droplet instance after it is activated.
First it is better to generate a dedicated SSH key for your Terraform scripts.

```bash
ssh-keygen
```

We will name that new key mc_rsa

```bash
Generating public/private rsa key pair.
Enter file in which to save the key (/your_home/.ssh/id_rsa): mc_rsa
```

## Connect doctl with your Digital Ocean account

Run `doctl auth init` command.
Go to your Digital Ocean accout under API and click Generate New Token.
Then copy your token into the terminal.
Now your doctl have access to your account information.

## Configure your terraform variables

Inside the project copy the example environment variable

```bash
cp terraform.tfvars.example terraform.tfvars
```

Make sure you set the Required variables. You can set the Optional variables if you don't like the defaults.  
For information about Droplet sizes run the following command: `doctl compute size list --output json | less`.
This will give your information about available droplets. When you have chose your droplet size take note of your droplet slug and region and input it in your terraform.tfvars file.
My go to droplets are `s-1vcpu-1gb` and `s-2vcpu-4gb`.

### Docker-Compose

If you change the default droplet size don't forget to update the `docker-compose.yml` file in the upload folder to reflect your chose of droplet.

#### Examples

##### s-1vcpu-1gb

```bash
command: "java -Xms512M -Xmx512M -jar server.jar"
```

##### s-2vcpu-4gb

```bash
command: "java -Xms3072M -Xmx3584M -jar server.jar"
```

### Discord Intergration

You can enable Discord webhook intergration.
To do so create a webhook and set the webhook variable in terraform.tfvars.

#### Examples

##### On server creation

```bash
CoronerBot BOT Today at 10:04 PM
Minecraft server mc-server has just been created, may take up to 2 minutes for everything to load. IP: 64.227.67.164
```

##### On server deletion

```bash
CoronerBot BOT Today at 10:04 PM
The Minecraft server mc-server at IP 64.227.67.164 is shutting down.
```

## Run your Minecraft Server

Now the hard part is done time to run your Minecraft Server with some simple commands. Make sure you are in the terraform folder and then run the following commands

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

Then after reviewing your configuration write `yes`

Once terraform finishes deploying the Droplet it will print your External IP in your terminal. You may have to wait few more minutes until the Minecraft Server finished loading. To connect to the console of your server your can use mcrcon as following

```bash
mcrcon -H <Your-Server-ip> -p <your-rcon-password>
```

## Destroy your Minecraft Server

From inside the terraform folder type the following command

```bash
terraform destroy
```

Then after reviewing your configuration type `yes`

Your minecraft server will be gracefully shut down. The world and server configuration will then compressed and downloaded in to your local Minecraft Server folder.
Then it will continue to destory the Droplet.
