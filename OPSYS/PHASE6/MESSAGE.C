/* Erick Nave
   Operating Systems
   Phase 4 - Message Passing
 
   Phase 4 implements a facility for interprocess communication.
     Message.c provides a mechanism through which processes may send
     messages to each other.  */
 
#include <stdio.h>
#include <string.h>
#include "memory.h"
#include "process.h"
#include "sema.h"
#include "message.h"
#pragma inline memcpy
#pragma inline memcmp
 
int send_(int dest, void *msg, int msglen)
/* send_() expects the destination process's PIN (dest), the address of
     the buffer containing the message (msg), and the length of the
      message (msglen).  It returns -1 of the PIN is invalid.  It copies
      the message to the receiver's buffer and returns 0. */
{
 int i;      /* loop index */
 int pos;    /* position in PTable of dest PIN */
 int buflen; /* length of msg buffer */
 int check;  /* check return code for P_ and V_ */
 
                /* search for dest PIN */
 for (i=0, pos=0; i < PTSIZE && pos == 0; i++)
  if (PTable[i].pin == dest) pos = i;
 
 if (pos == 0) return -1;  /* not found */
 else
  {
   check = P_((semaptr)PTable[pos].OKToSend);
   if (check == -1) return -1;
   if (msglen > PTable[pos].msglen) buflen = PTable[pos].msglen;
   else buflen = msglen;
   memcpy(PTable[pos].msgaddr, msg, buflen);
   PTable[pos].SenderPIN = running->pin;
   check = V_((semaptr)PTable[pos].OKToReceive);
   if (check == -1) return -1;
   return 0;
  }
} /* end send_() */
 
 
int receive_(void *buf, int buflen)
/* receive expects as parameters the address of a buffer into which to
    receive the message text (buf) and the length of the buffer (buflen).
    It sets the receiving process's msgaddr and msglen fields to these
    parameters.  It returns the PIN of the sending process. */
{
 running->msgaddr = buf;
 running->msglen = buflen;
 V_((semaptr)running->OKToSend);
 P_((semaptr)running->OKToReceive);
 return running->SenderPIN;
} /* end receive_() */
