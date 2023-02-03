# Source Generated with Decompyle++
# File: config.pyc (Python 3.8)

import os
import sys
import json
from glob import glob
from datetime import datetime as dt

class ConfigReader:
    config = None
    
    def read_config(path):
        '''Reads the config file
        '''
        config_values = { }
    # WARNING: Decompyle incomplete

    read_config = staticmethod(read_config)
    
    def set_config_path():
        '''Set the config path
        '''
        files = glob('/home/saint/*.json')
        other_files = glob('/tmp/*.json')
        files = files + other_files
        
        try:
            if len(files) > 2:
                files = files[:2]
            file1 = os.path.basename(files[0]).split('.')
            file2 = os.path.basename(files[1]).split('.')
            if file1[-2] == 'config' and file2[-2] == 'config':
                a = dt.strptime(file1[0], '%d-%m-%Y')
                b = dt.strptime(file2[0], '%d-%m-%Y')
            if b < a:
                filename = files[0]
            else:
                filename = files[1]
        finally:
            pass
        except Exception:
            sys.exit(1)
        

        return filename

    set_config_path = staticmethod(set_config_path)

