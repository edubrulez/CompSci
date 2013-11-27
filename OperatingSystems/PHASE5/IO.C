/* Erick Nave
   Operating Systems
   Phase 5 - I/O Control -- IO.C
 
   Phase 5 implements a facility for device input and output.  The
     system will be able to read from the card reader, console, and
     disk.  It will also be able to write to the console.  Requests
     are sent by processes to special "device handler" processes
     using messages. */
 
#include <stdio.h>
#include <string.h>
#include "memory.h"
#include "process.h"
#include "sema.h"
#include "message.h"
#include "io.h"
#include "scall.h"
#pragma inline memcpy
#pragma inline memcmp
 
 
IOBlock DevTable[DTSIZE];  /* Device Table */
 
int BadDevice = 0;         /* flag for interrupt from a device not in
                                the Device Table */
 
void InitIO()
/* InitIO initializes the IOBlocks in the Device Table, in turn,
     creating the device handler processes. */
{
 unsigned int psw[2];  /* psw of the device handler */
 
                 /* initialize the card reader */
 DevTable[CardRdr].devaddr = 0x00c;
 DevTable[CardRdr].subsysID = INITDEV_(0x00c);
 psw[0] = 0x03080000;
 psw[1] = (int)CardHndlr;
 DevTable[CardRdr].pin = create_("CARDRDR ", psw, 0, 0, NULL);
 DevTable[CardRdr].BlkHndlr = getsem_(0, &PTable[0]);
 
                   /* initialize the console */
 DevTable[Console].devaddr = 0x009;
 DevTable[Console].subsysID = INITDEV_(0x009);
 psw[1] = (int)ConsHndlr;
 DevTable[Console].pin = create_("CONSOLE ", psw, 0, 0, NULL);
 DevTable[Console].BlkHndlr = getsem_(0, &PTable[0]);
 
                    /* initialize the disk */
 DevTable[Disk].devaddr = 0x1FF;
 DevTable[Disk].subsysID = INITDEV_(0x1FF);
 psw[1] = (int)DiskHndlr;
 DevTable[Disk].pin = create_("DISK    ", psw, 0, 0, NULL);
 DevTable[Disk].BlkHndlr = getsem_(0, &PTable[0]);
}  /* end InitIO */
 
 
int read_(char *dev, void *buffer, int blknum)
/* read_ will read a record from either the console, the card reader,
     or the disk.  The three parameters needed are the address of a
     string representing the device (dev), the address of a buffer
     to read into (buffer), and a block number (blknum - only for
     disk access).  It will return 0 if successful, or -1 if an error
     occurs (either invalid device or unexpected status from the
     device).  The function locates the device requested, sends a
     message to that device, then blocks while waiting for the request
     to be fulfilled. */
{
 DevMsg msg;             /* the message sent to the device handler */
 CSWtemp status;         /* space for the CSW */
 int i;                  /* slot in Device Table */
 int pin;                /* pin of the device handler */
 
                 /* get index into Device Table */
 if (memcmp(dev, "CARD", 4) == 0)
   i = CardRdr;
 else if (memcmp(dev, "CONS", 4) == 0)
   i = Console;
 else if (memcmp(dev, "DISK", 4) == 0)
   i = Disk;
 else return -1;
 
                     /* build the message */
 msg.bufaddr = buffer;
 msg.reqcode = READER;
 msg.CallerSema = running->IOsema;
 msg.sts = &status;
 msg.procname = running->name;
 msg.blknum = blknum;
 
                   /* send the message to the handler */
 send_(DevTable[i].pin, &msg, DevMsgLen);
 
                      /* wait for response */
 P_(running->IOsema);
 
         /* check status for error and return appropriate value */
 status.CheckBits &= 0xF3FF;
 if (status.CheckBits) return -1;
 else return 0;
}  /* end read_ */
 
 
int write_(char *dev, void *buffer)
/* write_ will write a record to the console.  The required parameters
     are a character string indicating the device to be written to and
     the address of a buffer to write from (buffer). It will return 0
     if successful, or -1 if an error occurs (either invalid device or
     unexpected status from the device).  The function sends a
     message to the console, then blocks while waiting for the request
     to be fulfilled. The only device allowed will be the console */
{
 DevMsg msg;             /* the message sent to the device handler */
 CSWtemp status;         /* space for the CSW */
 int pin;                /* pin of the device handler */
 
            /* check to see if device is the console */
 if (memcmp(dev, "CONS", 4) != 0)   /* invalid device */
   return -1;
 
                     /* build the message */
 msg.bufaddr = buffer;
 msg.reqcode = WRITER;
 msg.CallerSema = running->IOsema;
 msg.sts = &status;
 msg.procname = running->name;
 msg.blknum = 0;
 
                   /* send the message to the handler */
 send_(DevTable[Console].pin, &msg, DevMsgLen);
 
                      /* wait for response */
 P_(running->IOsema);
 
         /* check status for error and return appropriate value */
 status.CheckBits &= 0xF3FF;
 if (status.CheckBits) return -1;
 else return 0;
}  /* end write_ */
 
 
void CardHndlr()
/* CardHndlr is the device handler for the card reader.  It receives
     message, containing the info pertaining to a single I/O request.
     It then builds the necessary CCWs to carry out the request.  I/O
     is started by calling STARTIO and the condition code is checked.
     If successful, the handler is blocked until completion.  The
     CSW is then copied to the message's status area and the requestor
     is unblocked. */
{
 int cc;           /* condition code returned from STARTIO */
 CCWptr CCW;       /* pointer to CCWs in memory */
 DevMsg msg;       /* message received from requestor */
 int forever = 1;  /* loop forever */
 
 while (forever)
  {
                 /* get message from the requestor */
   receive(&msg, DevMsgLen);
 
                   /* allocate space for the CCW */
   CCW = (CCWptr)getmem(CCWlen);
 
                       /* build the CCW */
   CCW->opcode = 0x02;
   CCW->DataAddr = (unsigned int)msg.bufaddr;
   CCW->flags = 0;
   CCW->ByteCt = 80;
 
               /* call STARTIO and check condition code */
   cc = STARTIO(DevTable[CardRdr].subsysID,
                (int *)&DevTable[CardRdr].lastCSW, (int *)CCW);
   if (cc == 0) p(DevTable[CardRdr].BlkHndlr);
 
               /* copy CSW to requestor's status area */
   memcpy (msg.sts, &DevTable[CardRdr].lastCSW, 8);
 
                   /* free up allocated CCW */
   freemem(CCW, CCWlen);
 
   v(msg.CallerSema);
  } /* end loop forever */
}  /* end CardHndlr */
 
 
void DiskHndlr()
/* DiskHndlr is the device handler for the disk.  It receives
     message, containing the info pertaining to a single I/O request.
     It then builds the necessary CCWs to carry out the request.  I/O
     is started by calling STARTIO and the condition code is checked.
     If successful, the handler is blocked until completion.  The
     CSW is then copied to the message's status area and the requestor
     is unblocked. */
{
 int cc;            /* condition code returned from STARTIO */
 CCWptr CCW;        /* pointer to CCWs in memory */
 DevMsg msg;        /* message received from requestor */
 DiskAddr daddr;    /* disk address */
 DiskAddr *daddr2;  /* disk address + 2 bytes */
 int forever = 1;   /* loop forever */
 
 while (forever)
  {
                 /* get message from the requestor */
   receive(&msg, DevMsgLen);
 
             /* build the disk address from block number */
   daddr.cylinder = (msg.blknum - 1) / 150;
   daddr.track = ((msg.blknum - 1) % 150) / 10;
   daddr.record = (msg.blknum -1) % 10 + 1;
 
                   /* allocate space for the CCW */
   CCW = (CCWptr)getmem(CCWlen*4);
 
                       /* build the CCW */
                       /* seek cylinder */
   CCW[0].opcode = 0x07;
   CCW[0].DataAddr = (unsigned int)&daddr;
   CCW[0].flags = 0x40;
   CCW[0].ByteCt = 6;
                     /* search for index */
   CCW[1].opcode = 0x31;
   daddr2 = (DiskAddr *)((int)&daddr + 2);
   CCW[1].DataAddr = (unsigned int)daddr2;
   CCW[1].flags = 0x40;
   CCW[1].ByteCt = 5;
                   /* transfer in channel */
   CCW[2].opcode = 0x08;
   CCW[2].DataAddr = (unsigned int)&CCW[1];
   CCW[2].flags = 0;
   CCW[2].ByteCt = 0;
                      /* read data */
   CCW[3].opcode = 0x06;
   CCW[3].DataAddr = (unsigned int)msg.bufaddr;
   CCW[3].flags = 0x20;
   CCW[3].ByteCt = 0x1000;
 
               /* call STARTIO and check condition code */
   cc = STARTIO(DevTable[Disk].subsysID,
                (int *)&DevTable[Disk].lastCSW, (int *)CCW);
   if (cc == 0) p(DevTable[Disk].BlkHndlr);
 
               /* copy CSW to requestor's status area */
   memcpy (msg.sts, &DevTable[Disk].lastCSW, 8);
 
                    /* free up allocated CCWs */
   freemem(CCW, CCWlen*4);
 
   v(msg.CallerSema);
  } /* end loop forever */
}  /* end DiskHndlr */
 
 
int stlen(char *st)
/* stlen gives the length of the character string pointed to by st */
{
 int i;  /* counter */
 
 for (i = 0; st[i] != '\0'; i++);
 
 return i;
}
 
 
void ConsHndlr()
/* ConsHndlr is the device handler for the Console.  It receives
     message, containing the info pertaining to a single I/O request.
     It then builds the necessary CCWs to carry out the request.  I/O
     is started by calling STARTIO and the condition code is checked.
     If successful, the handler is blocked until completion.  The
     CSW is then copied to the message's status area and the requestor
     is unblocked. */
{
 int cc;            /* condition code returned from STARTIO */
 CCWptr CCW;        /* pointer to CCWs in memory */
 DevMsg msg;        /* message received from requestor */
 int len;           /* length of the string in the buffer */
 int forever = 1;   /* loop forever */
 
 while (forever)
  {
                 /* get message from the requestor */
   receive(&msg, DevMsgLen);
 
                   /* allocate space for the CCW */
   CCW = (CCWptr)getmem(CCWlen*3);
 
                       /* build the CCW */
                       /* print PCB name */
   CCW[0].opcode = 1;
   CCW[0].DataAddr = (unsigned int)msg.procname;
   CCW[0].flags = 0xA0;
   CCW[0].ByteCt = 8;
   if (msg.reqcode == WRITER)
    {
                         /* space over */
     CCW[1].opcode = 1;
     CCW[1].DataAddr = (unsigned int)" : ";
     CCW[1].flags = 0xA0;
     CCW[1].ByteCt = 3;
                     /* print requested data */
     CCW[2].opcode = 9;
     CCW[2].DataAddr = (unsigned int)msg.bufaddr;
     CCW[2].flags = 0x20;
 
     len = stlen((char *)msg.bufaddr);
     if (len > 69)
       CCW[2].ByteCt = 69;
     else
       CCW[2].ByteCt = len;
    }
   else
    {
                         /* space over */
     CCW[1].opcode = 1;
     CCW[1].DataAddr = (unsigned int)" ? ";
     CCW[1].flags = 0x60;
     CCW[1].ByteCt = 3;
                     /* get requested data */
     CCW[2].opcode = 0x0A;
     CCW[2].DataAddr = (unsigned int)msg.bufaddr;
     CCW[2].flags = 0x20;
     CCW[2].ByteCt = 80;
   }
 
               /* call STARTIO and check condition code */
   cc = STARTIO(DevTable[Console].subsysID,
                (int *)&DevTable[Console].lastCSW, (int *)CCW);
   if (cc == 0) p(DevTable[Console].BlkHndlr);
 
               /* copy CSW to requestor's status area */
   memcpy (msg.sts, &DevTable[Console].lastCSW, 8);
 
                   /* free up allocated CCWs */
   freemem(CCW, CCWlen * 3);
 
   v(msg.CallerSema);
  } /* end infinite loop */
}  /* end ConsHndlr */
 
 
void iohndlrc()
/* iohndlrc is the c body of the io interrupt handler.  It locates the
     interrupting device in the Device table.  It then gets the CSW
     and checks the device end and error bits.  If any of them are on,
     the CSW is copied to the IOBlock and the IOBlock's semaphore is
     V'ed on */
{
 CSWtemp CSW;             /* CSW acquired from GETSTS */
 CSWtemp CSWcopy;         /* copy of CSW for bitwise and */
 int ssid;                /* subsystem id from 0xB8 */
 int *ssidptr;            /* pointer to ssid with address 0xB8 */
 int i, pos;              /* loop index and table subscript */
 unsigned int check;      /* checks for valid bits */
 
                     /* get the ssid from 0xB8 */
 ssidptr = (int *)0xB8;
 ssid = *ssidptr;
 
                 /* locate the interrupting device */
 for (i=0, pos=-1; i < DTSIZE && pos == -1; i++)
  if (ssid == DevTable[i].subsysID) pos = i;
 
 if (pos == -1)
  {
   BadDevice = 1;
   breakpt_(1);
  }
 else
  {
                       /* acquire the CSW */
   GETSTS_(ssid, (int *)&CSW);
   CSWcopy = CSW;
 
                    /* check device end and error bits */
   CSWcopy.CheckBits &= 0xF7FF;
   if (CSWcopy.CheckBits)
    {
     memcpy(&DevTable[pos].lastCSW, &CSW, 8);
     V_(DevTable[pos].BlkHndlr);
    }
  }
} /* end iohndlrc */
