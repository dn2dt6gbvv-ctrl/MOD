



   
#if defined _datagram_included
  #endinput
#endif
#define _datagram_included
#pragma library DGram

native sendstring(const message[], const destination[]="");
native sendpacket(const packet[], size, const destination[]="");

native listenport(port);

forward @receivestring(const message[], const source[]);
forward @receivepacket(const packet[], size, const source[]);
