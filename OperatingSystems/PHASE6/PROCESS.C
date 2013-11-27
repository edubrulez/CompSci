/* Erick Nave
   Operating Systems
   Phase 2 - Process Control -- Process.C
 
   Phase 2 introduces basic processes and time-slicing.  The system will
     create several processes and contorl their execution. */
 
#include <stdio.h>
#include <string.h>
#include "memory.h"
#include "process.h"
#include "sema.h"
#include "message.h"
#include "scall.h"
#include "io.h"
#include "job.h"
#pragma inline memcpy
#pragma inline memcmp
 
 
                 /* global system variables */
PCB PTable[PTSIZE];       /* Process Table */
 
Que Ready;                /* Ready Process Queue */
 
PCBptr running;           /* ptr to running PCB */
 
int pinct = 0;            /* PIN accumulator */
 
semaptr PTSEM, MEMWAIT;   /* semaphores for PTable and memory */
 
int tpin;                 /* terminator's PIN */
 
int PCOUNT = 0;
 
 
                       /* Queue ADT */
void QInit(Que *Q)
/* QInit initializes the process queue by setting fornt and rear
     to NULL */
{
 Q->front = NULL;
 Q->rear = NULL;
}
 
int QEmpty(Que *Q)
/* QEmpty returns 1 if the Q is empty (front == NULL) and 0 otherwise */
{
 return (Q->front == NULL);
}
 
void enQ(PCBptr p, Que *Q)
/* enQ puts the PCB onto the end of the  Q */
{
 p->next = NULL;
 if (QEmpty(Q))
  Q->front = p;
 else
   Q->rear->next = p;
 Q->rear =  p;
}
 
PCBptr deQ(Que *Q)
/* deQ returns the first member of the Q */
{
 PCBptr retval; /* return value */
 
 if(!QEmpty(Q))
  {
   retval = Q->front;
   Q->front = Q->front->next;
  }
 else retval = (PCBptr)0;
 
 if (QEmpty(Q))
  Q->rear = NULL;
 
 return retval;
}
 
 
void dispatch()
/* dispatch determines which process is to run next and transfers
    control to that process. */
{
 PCBptr oldrun = running;
 
 if ((running->state == DISPATCH) && (running->pin != 1))
   enQ(running, &Ready);
 
                       /* get next process */
 running = deQ(&Ready);
 
 if (running == 0)
  running = &(PTable[0]); /* wait process */
 
                        /* set CPU timer */
 SPT_(26);
 
                 /* save old stack ptr and load new one */
 if (running->state == NEW)
  {
   running->state = DISPATCH;
   CSWITCH1(&oldrun->top, running->regs);
  }
 else CSWITCH(&oldrun->top, &running->top);
} /* end dispatch */
 
 
int create_(char *pname, unsigned int *psw, void *ustack, int narg,
            void *argptr)
/* create creates a new PCB containing the information to make the
     program "runnable" in the OS.  It locates an unused slot in the
     Process Table, initializes it, and attaches it to the end of the
     process queue.  It expects as parameters: ptr to the process name,
     address of the initial psw of the process, the address of a
     memory area to be used a the process's user stack (if 0 then
     allocate the space for it), the number of parameters to be
     passed as child processes, and the address of an array containing
     the parameters to be passed to the child. */
{
 int pos = 0; /* position in the table */
 int i;       /* loop index for registers */
 
 P_(PTSEM);
               /* locate empty slot in process table */
 while (PTable[pos].state != UNUSED && pos < PTSIZE)
   pos++;
 
 if (pos == PTSIZE)
  return -1;    /* table full */
 else
  {
   pinct++;
                         /* assign type */
   memcpy(PTable[pos].type, "PCB ", 4);
                         /* assign pin */
   PTable[pos].pin = pinct;
                         /* assign name */
   memcpy(PTable[pos].name, pname, 8);
                      /* assign state of NEW */
   PTable[pos].state = NEW;
                   /* allocate stack space */
   PTable[pos].kernal = getmem_(0x1000);
   if (ustack == 0)
    PTable[pos].user = getmem_(0x1000);
   else PTable[pos].user = ustack;
           /* copy contents of parameter array on to user stack */
   memcpy(PTable[pos].user, argptr, narg*4);
 
             /* initialize PSW and increment job counter */
   if (running->jobkey != 0)
    {
     PTable[pos].jobkey = running->jobkey;
     psw[0] &= 0xFF0FFFFF;
     psw[0] |= running->jobkey << 20;
    }
   else
     PTable[pos].jobkey = (psw[0] & 0x00F00000) >> 20;
   PTable[pos].psw[0] = psw[0];
   PTable[pos].psw[1] = psw[1];
   JobTable[PTable[pos].jobkey].procs += 1;
 
                    /* initialize registers */
   for (i=0; i<16; i++)
    PTable[pos].regs[i] = 0xFAFAFAFA;
   PTable[pos].regs[11] = psw[1];
   PTable[pos].regs[12] = (unsigned int)PTable[pos].user;
   PTable[pos].regs[13] = (int)KILL;
          /* initialize semact and owned semaphore array */
   PTable[pos].semact = 0;
   for (i=0; i<MAXSEMAS; i++)
    PTable[pos].owns[i] = NULL;
             /* initialize OKToSend and OKToRecieve semaphores */
   PTable[pos].OKToSend = getsem_(0, &(PTable[pos]));
   PTable[pos].OKToReceive = getsem_(0, &PTable[pos]);
             /* initialize msglen and SenderPIN to 0 */
   PTable[pos].msglen = 0;
   PTable[pos].SenderPIN = 0;
                 /* create the I/O semaphore */
   PTable[pos].IOsema = getsem_(0, &PTable[pos]);
             /* place the new process on the ready Q */
   enQ(&(PTable[pos]), &Ready);
   return pinct;
  }
} /* end create_() */
 
 
void destroy_(int term)
/* destroy_() sets the process state to DELETE.  It then calls
    dispatch(). The argument term is an integer indicating if the
    termination is normal (0) or abnormal (1). */
{
 running->termsts = term;
 send_(tpin, &running, 4);
 running->state = DELETE;
 dispatch();
} /* end destroy_() */
 
 
void terminator()
/* terminator is a system process that cleans up after processes being
    destroyed.  It receives a message from destroy_() telling it which
    PCB is to be terminated.  It then frees the process's PTable slot
    and the memory space allocated to the process's stacks and
    semaphores.  If the process is the last one belonging to a job,
    the job table slot is then cleared.  A message indicating
    termination status is then written to the console */
{
 int loopforever = 1; /* while loop will always be true */
 PCBptr killed;       /* addr of PCB to be terminated */
 int i;               /* loop index for semaphore array */
 int jkey;            /* job key for terminating process */
 int memend;          /* end of job's memory region */
 char msg[80];        /* termination message buffer */
 
 while (loopforever)
  {
   receive(&killed, 4);
   killed->state = DELETE;
   if (killed->termsts == 0)
    {
     sprintf(msg, "PROCESS %s TERMINATED NORMALLY: RETURN %x",
              killed->name, killed->regs[11]);
     write("CONS", msg);
    }
   else
    {               /* abnormal termination */
     sprintf(msg, "PROCESS %s TERMINATED ABNORMALLY", killed->name);
     write("CONS", msg);
     sprintf(msg, "PSW = %0X %0X", killed->psw[0], killed->psw[1]);
     write("CONS", msg);
     for (i=0; i<15; i+=4)
      {
       sprintf(msg, "GPR%d: %0X  %0X  %0X  %0X", i,  killed->regs[i],
        killed->regs[i+1], killed->regs[i+2], killed->regs[i+3]);
       write("CONS", msg);
      }
    }
                     /* decrement job process counter */
   jkey = killed->jobkey;
   JobTable[jkey].procs -= 1;
                          /* free stack space */
   if (JobTable[jkey].procs == 0)
    {
     memend = (int)JobTable[jkey].region + JobTable[jkey].len;
     for (i = (int)JobTable[jkey].region; i < memend; i += 0x1000)
      SSKEASM(0, i);
     freemem(JobTable[jkey].region, JobTable[jkey].len);
     sprintf(msg, "JOB %s TERMINATED", JobTable[jkey].name);
     write("CONS", msg);
     JobTable[jkey].inuse = 0;
     v(SKsem);
    }
   freemem(killed->kernal, 0x1000);
                     /* free all owned semaphores */
   for (i=0; i < killed->semact; i++)
    freesem(killed->owns[i]);
   killed->state = UNUSED;
   v(PTSEM);
  }
} /* end terminator */
 
 
void main()
{
 void *npswloc;             /* new psw location address */
 unsigned int psw[2];       /* psw */
 int x;                     /* loop index */
 int wpin, jpin;            /* pin for the wait and job processes */
 PCB dummypcb;              /* dummy PCB for running to be set to */
 char msg[80];
 
                  /* initialize new psw locations */
 psw[0] = 0x00080000;
                       /* program interrupt */
 psw[1] = (int)PRGHNDLR;
 npswloc = (void *)0x68;
 memcpy(npswloc, psw, 8);
                        /* I/O interrupt */
 psw[1] = (int)IOHNDLR;
 npswloc = (void *)ioint;
 memcpy(npswloc, psw, 8);
                       /* External interrupt */
 psw[1] = (int)EXTHNDLR;
 npswloc = (void *)extint;
 memcpy(npswloc, psw, 8);
                         /* SVC interrupt */
 psw[1] = (int)SVCHNDLR;
 npswloc = (void *)svcint;
 memcpy(npswloc, psw, 8);
 
                     /* initialize memory */
 initmem_();
 
                  /* initialize Ready Process Q */
 QInit(&Ready);
 
               /* initialize table to all empty slots */
 for (x=0; x<PTSIZE; x++)
  {
   PTable[x].state = UNUSED;
   PTable[x].jobkey = PTable[x].termsts = 0;
  }
 memcpy(dummypcb.name, "        ", 8);
 
                /* initialize all storage keys to 0 */
 for (x=0; x<0x300000; x+=0x1000)
  SSKEASM(0,x);
 
                 /* initialize running to dummy PCB */
 running = &dummypcb;
 running->state = BLOCKED;
 running->jobkey = 0;
 
                     /* create WAIT process */
 psw[0] = 0x030A0000;
 psw[1] = 0x0000AAAA;
 wpin = create_("WAIT    ", psw, NULL, 0, NULL);
 deQ(&Ready);
 
                   /* create PTSEM and MEMWAIT */
 PTSEM = getsem_(PTSIZE-1, &(PTable[0]));
 MEMWAIT = getsem_(0, &PTable[0]);
 
                    /* create terminator process */
 psw[0] = 0x3080000;
 psw[1] = (int)terminator;
 tpin = create_("TERMINAT", psw, 0, 0, NULL);
 
                   /* create I/O handler processes */
 InitIO();
 
                   /* create job control process */
 psw[0] = 0x03080000;
 psw[1] = (int)jobcntrl;
 jpin = create_("JOBCNTRL", psw, 0, 0, NULL);
 
                /* dispatch to give control to 1st job */
 dispatch();
} /* end main */
