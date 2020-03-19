'''
Basic webhook wrapper for sending messages to discord chat.
'''
from discord_webhook import DiscordWebhook
import argparse

if __name__ == '__main__':
    ## initiate the parser with a description
    parser = argparse.ArgumentParser(description = 'Basic webhook bot for discord')
    optional = parser._action_groups.pop()
    optional.add_argument("--skipmessage",default=False)
    optional.add_argument("-u", "--uri", help="Webook Uri")
    optional.add_argument("-c", "--content", help="Content to send")
    cmdargs = parser.parse_args()
    if cmdargs.skipmessage == "false": 
        webhook = DiscordWebhook(url=cmdargs.uri, content=cmdargs.content)
        response = webhook.execute()