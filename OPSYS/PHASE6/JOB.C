/* Erick Nave
   Operating Systems
   Phase 6 -- job control -- job.c
 
   Phase 6 adds a high-level job control process to the O.S..  The
      job control process will read object files from the virtual card
      reader, load them into memory, and let them execute.  This will
      implement a variable-partition multiprogramming system. */
 
#include <stdio.h>
#include <string.h>
#include "memory.h"
#include "process.h"
#include "sema.h"
#include "message.h"
#include "io.h"
#include "job.h"
#include "scall.h"
#pragma inline memcpy
#pragma inline memcmp
 
 
job JobTable[MaxJobs];   /* Job Table */
 
int StKey;               /* status key */
 
semaptr SKsem;           /* status key semaphore */
 
semaptr ReaderEmpty;     /* block when card reader is empty */
 
objrec obj;           /* object record read from the card reader */
 
 
void jobcntrl()
/* jobcntrl is the job control process.  Its function is to admit new
     jobs to the system.  For each job, it allocates a region of
     contiguous 4K blocks of memory (for the program and its user
     stack), loads the job into the region, assigns a storage key to
     the job, then uses SSKE to set the key for each 4K block in the
     region, and creates an initial process to execute the job.
     Input will be a series of object files read from the virtual
     card reader. */
{
 int size;             /* size of memory block */
 int user;             /* ptr to user stack */
 int r;                /* ptr to program memory region */
 void *mem;            /* ptr to memory block from getmem */
 int gmfail = 0;       /* set to 1 if getmem_ fails */
 int i;                /* loop index */
 int forever = 1;      /* loop forever */
 int key;              /* Status key fudged for SSKE instruction */
 void *txtaddr;        /* address of place to copy text */
 unsigned int psw[2];  /* copy of psw */
 char msg[80];         /* buffer for job start message */
 int rem;
 
            /* allocate Storage Key and Empty reader semaphores */
 SKsem = getsem(15);
 ReaderEmpty = getsem(0);
 
             /* initialize JobTable entries to unused */
 for (i=1; i<MaxJobs; i++)
  JobTable[i].inuse = JobTable[i].procs = 0;
 
             /* mark subscript 0 as used by operating system */
 JobTable[0].inuse = 1;
 memcpy(JobTable[0].name, "OPSYS   ", 8);
 
 while (forever)
  {
   while (read("CARD", &obj, 0) == 0)
    {
          /* if its an ESD record, get memory and set job block */
     if (memcmp(obj.esd.rectype, "ESD", 3) == 0)
      {
             /* find open slot and set Status Key */
       p(SKsem);
       for (i=1; i<MaxJobs && JobTable[i].inuse != 0; i++);
       StKey = i;
                   /* allocate memory */
       size = (obj.esd.len + 0x1FFF) & 0xFFFFF000;
       mem = getmem(size + 0x1000);
       if (mem == 0)
        {  /* program too large for entire memory -- don't set up job */
         gmfail = 1;
         v(SKsem);
        }
       else
        {     /* program can fit -- set up job */
         user = ((int)mem + 0xFFF) & 0xFFFFF000;
         r = user + 0x1000;
                 /* set status key for blocks */
         key = StKey << 4;     /* shift over 4 for sske instruction */
         key |= 0x00000008;    /* turn on fetch bit */
         for (i = user; i < user + size; i += 0x1000)
          SSKEASM(key, i);
                   /* set up job block */
         JobTable[StKey].inuse = 1;
         memcpy(JobTable[StKey].name, &obj.esd.name, 8);
         JobTable[StKey].region = mem;
         JobTable[StKey].len = size + 0x1000;
         JobTable[StKey].procs = 0;
        }
      }
             /* if TXT record, load text into memory */
     if (memcmp(obj.txt.rectype, "TXT", 3) == 0)
      if (gmfail == 0)
       {
        txtaddr = (void *)(r + obj.txt.offset);
        memcpy(txtaddr, obj.txt.data, obj.txt.ByteCt);
       }
        /* if END record, set up PSW and create 1st process */
     if (memcmp(obj.end.rectype, "END", 3) == 0)
      if (gmfail == 1) gmfail = 0; /* reset getmem failure */
      else
       {
        psw[0] = 0x03090000;
        psw[0] |= StKey << 20;
        psw[1] = r + obj.end.offset;
        create(JobTable[StKey].name, psw, (void *)user, 0, NULL);
               /*  print start message */
        sprintf(msg,"JOB %s STARTED: STKEY %d REGN SIZE %X REGN ADDR %X",
           JobTable[StKey].name, StKey, size, user);
        write("CONS", msg);
       }
    } /* end while read */
   p(ReaderEmpty);
  } /* end loop forever */
} /* end jobcntrl */
 
 
void abend()
/* abend simply calls destroy with an argument of -1 indicating abnormal
     termination.  It is called by the program interrupt handler */
{
 destroy_(-1);
} /* end abend */
