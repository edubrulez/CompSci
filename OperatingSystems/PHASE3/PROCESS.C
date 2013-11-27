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
#pragma inline memcpy
#pragma inline memcmp
 
                 /* global system variables */
PCB PTable[PTSIZE];       /* Process Table */
 
Que Ready;                /* Ready Process Queue */
 
PCBptr running;           /* ptr to running PCB */
 
int pinct = 0;            /* PIN accumulator */
 
semaptr PTSEM, MEMWAIT;   /* semaphores for PTable and memory */
 
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
           /* copy sontents of parameter array onth user stack */
   memcpy(PTable[pos].user, argptr, narg*4);
                     /* initialize PSW */
   PTable[pos].psw[0] = psw[0];
   PTable[pos].psw[1] = psw[1];
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
 running->state = DELETE;
 dispatch();
} /* end destroy_() */
 
void main()
{
 void *npswloc;             /* new psw location address */
 unsigned int psw[2];       /* psw */
 int x;                     /* loop index */
 int wpin, rpin;            /* pin for the wait and root states */
 PCB dummypcb;              /* dummy PCB for running to be set to */
 
                  /* initialize new psw locations */
                       /* program interrupt */
 psw[0] = 0x000A0000;
 psw[1] = 0x00000BAD;
 npswloc = (void *)progint;
 memcpy(npswloc, psw, 16);
                        /* I/O interrupt */
 psw[0] = 0x00080000;
 psw[1] = (int)IOHNDLR;
 npswloc = (void *)ioint;
 memcpy(npswloc, psw, 16);
                       /* External interrupt */
 psw[1] = (int)EXTHNDLR;
 npswloc = (void *)extint;
 memcpy(npswloc, psw, 16);
                         /* SVC interrupt */
 psw[1] = (int)SVCHNDLR;
 npswloc = (void *)svcint;
 memcpy(npswloc, psw, 16);
 
                     /* initialize memory */
 initmem_();
 
                  /* initialize Ready Process Q */
 QInit(&Ready);
 
               /* initialize table to all empty slots */
 for (x=0; x<PTSIZE; x++)
  PTable[x].state = UNUSED;
 
                     /* create WAIT process */
 psw[0] = 0x030A0000;
 psw[1] = 0x0000AAAA;
 wpin = create_("WAIT    ", psw, NULL, 0, NULL);
 deQ(&Ready);
 
                   /* create PTSEM and MEMWAIT */
 PTSEM = getsem_(PTSIZE, &(PTable[0]));
 MEMWAIT = getsem_(0, &PTable[0]);
 
                 /* create 1st user (ROOT) process */
 psw[0] = 0x03080000;
 psw[1] = (int)root;
 rpin = create_("ROOT    ", psw, 0, 0, NULL);
 
                 /* initialize running to dummy PCB */
 running = &dummypcb;
 running->state = BLOCKED;
 
                 /* dispatch to give control to ROOT */
 dispatch();
} /* end main */
