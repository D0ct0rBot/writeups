# Source Generated with Decompyle++
# File: syncer.pyc (Python 3.8)

from configuration import *
from connectors.ftpconn import *
from connectors.sshconn import *
from connectors.utils import *

def main():
    '''Main function
    Cron job is going to make my work easy peasy
    '''
    configPath = ConfigReader.set_config_path()
    config = ConfigReader.read_config(configPath)
    connections = checker(config)
    if 'FTP' in connections:
        ftpcon(config['FTP'])
    elif 'SSH' in connections:
        sshcon(config['SSH'])
    elif 'URL' in connections:
        sync(config['URL'], config['Output'])

if __name__ == '__main__':
    main()
