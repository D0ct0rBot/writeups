#!/usr/bin/python3
import sys

if len(sys.argv) < 3 :
    print("Incorrect number of arguments. Usage:")
    print("     ", sys.argv[0], "<message_in_file> <key>");
    sys.exit(1)

filename = sys.argv[1]
key = sys.argv[2]

message=""
with open(filename, "rb") as f:
    message = f.read()
 
newkey=""
while len(message) > len(newkey) :
    newkey = newkey + key

# print ("Message=", message," Len=", len(message))
# print ("Key=", newkey," Len=", len(newkey))

encodedMessage=""

i = 0
for a in message :
    a = message[i]
    b = ord(newkey[i])
    value = a ^ b
    new = chr(value)

    encodedMessage = encodedMessage + new
    i = i + 1

print(encodedMessage)
