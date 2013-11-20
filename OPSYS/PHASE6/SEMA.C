/* Erick Nave
   Operating Systems
   Phase 3 -- Semaphores and SVCs
 
   Phase 3 introduces semaphores and the Supervisor call interface.
     The following functions deal with semaphores. */
 
#include <stdio.h>
#include <string.h>
#include "memory.h"
#include "process.h"
#include "sema.h"
#pragma inline memcpy
#pragma inline memcmp
 
semaptr getsem_(int initval, PCBptr proc)
/* getsem_ allocates and initializes a semaphore.  The arguments are
     the initial value for the semaphore (initval) and a pointer to
     the owner of the semaphore (proc).  The return value is the
     address of the semaphore.  If the maximum number of semaphores
     is exceeded, then a -1 is returned. */
{
 semaptr s; /* pointer to the new semaphore */
 
                /* if 2nd argument is 0, then owner is running */
 if (proc == (PCBptr)0) proc = running;
 
 if (proc->semact < MAXSEMAS)  /* room for another semaphore */
  {
                      /* get the memory */
   s = (semaptr)getmem_(20);
                  /* initialize the semaphore */
   memcpy(s->code, "SEMA", 4);
   s->ctr = initval;
   QInit(&(s->SQ));
   s->owner = proc;
                         /* place in owns array */
   proc->owns[proc->semact] = s;
   proc->semact += 1;
   return s;
  }
 else return (semaptr)-1;   /* no room in semaphore array */
} /* end getsem_ */
 
 
int freesem_(semaptr s)
/* freesem_ deallocates a semaphore.  It expects the handle to the
     semaphore as an argument.  Freesem must validate that the semaphore
     being freed is owned by the process doing the freesem (running).
     If this condition is not met a -1 is returned and the semaphore is
     not freed.  A 0 is returned if the semaphore is freed successfully.
     Processes waiting on the semaphore should be awakened and receive
     a return code of -1 from P_(). */
{
 PCBptr p;             /* pointer to PCBs on the semaphore's Q */
 int i=-1, found=0;     /* loop index and found indicator */
 
 if ((s->owner == running) || (running->pin == tpin))
    /* check to see if owner is valid or terminator process is running */
  {
   if (running->pin != tpin)
    {
                    /* remove from owns array */
     while (i < running->semact && !found)
      {
       i++;
       found = (s == (semaptr)running->owns[i]);
      }
     running->semact -= 1;
     for (i=i; i<running->semact; i++)
      running->owns[i] = running->owns[i+1];
    }
                      /* kill semaphore */
   memcpy(s->code, "    ", 4);  /* ensure return code of -1 from P_ */
             /* place waiting processes on the ready Q */
   while ((p = deQ(&(s->SQ))) != 0)
    {
     p->state = DISPATCH;
     p->waiton = (semaptr)-1;
     enQ(p,&Ready);
    }
                      /* free the memory */
   freemem_(s,20);
   return 0;
  }
 else return -1;   /* invalid owner */
} /* end freesem_ */
 
 
int P_(semaptr s)
/* P_ expects the argument of a semaphore handle.  If the calling process
    is to be blocked, then its state is changed to blocked, the PCB is
    added to the rear of the semaphore's blocked queue, the semaphore's
    handle is placed in the PCB of the blocked process, and dispatch is
    called.  0 is returned if successful, -1 if the argument is not a
    valid semaphore address. */
{
 if (memcmp(s->code, "SEMA", 4) == 0)
  {      /* valid address */
   s->ctr -= 1;
   if (s->ctr < 0)
    {        /* must block */
     running->state = BLOCKED;
     enQ(running, &(s->SQ));
     running->waiton = s;
     dispatch();
     if (running->waiton == (semaptr)-1)
       return -1;
     else return 0;
    }
   return 0;
  }
 else return -1;  /* invalid address */
} /* end P_ */
 
 
int V_(semaptr s)
/* V_ expects the handle of a semaphore (s) as an argument.  If a
     process is to be awakened, deQ a PCB from the semaphore's blocked
     Q, mark it as dispatchable, and enQ it to the ready Q.  If the
     calling process is the wait process, then V_ should call dispatch;
     else control returns to the caller.  0 is returned if successful.
     -1 is returned if the argument is not a valid semaphore. */
{
 PCBptr p;
 
 if (memcmp(s->code, "SEMA", 4) == 0)
  {      /* valid address */
   s->ctr += 1;
   if (s->ctr <= 0)
    {        /* must release */
     p = deQ(&(s->SQ));
     p->state = DISPATCH;
     p->waiton = NULL;
     enQ(p, &Ready);
     if (running->pin == 1) dispatch();
    }
   return 0;
  }
 else return -1;  /* invalid address */
} /* end V_ */
 
