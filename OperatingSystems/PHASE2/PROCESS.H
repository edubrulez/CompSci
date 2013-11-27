/* Erick Nave
   Operating Systems
   Phase 2 - Process Control -- Process.H
 
   This header contains declarations for Process Control */
 
                      /* macro definitions */
#ifndef PTSIZE
#define PTSIZE    30
#endif
 
             /* Type definitions for Process Control Block */
typedef struct PCBnode {
            char type[4];             /* PCB */
            char name[8];             /* process name */
            int pin;                  /* process id number */
            int state;                /* process state */
            struct PCBnode *next;     /* next PCB in queue */
            void *user;               /* pointer to user stack */
            void *kernal;             /* pointer to kernal stack */
            int top;                  /* stack pointer from R12 */
            unsigned int regs[16];    /* register save area */
            unsigned int psw[2];      /* PSW save area */
  } PCB;
 
typedef PCB *PCBptr;
 
extern PCB PTable[PTSIZE];    /* process table */
extern PCBptr running;        /* pointer to running process */
 
           /* declaration for Ready Process Queue structure */
typedef struct ReadyQueue {
          PCBptr front;
          PCBptr rear;
  } RPQ;
 
extern RPQ Ready;
 
extern void QInit();
extern void enQ(PCBptr);
extern PCBptr deQ();
extern int QEmpty();
 
                  /* definitions for process states */
#define UNUSED    0
#define NEW       1
#define DISPATCH  2
#define BLOCKED   3
#define DELETE    4
 
                  /* definitions for new psw locations */
#define extint    0x58   /* external interrupt */
#define progint   0x68   /* program interrupt */
#define ioint     0x78   /* I/O interrupt */
 
         /* external references for process control functions */
extern void dispatch();
extern int create_(char*,unsigned int*,void*,int,void*);
extern void destroy_(int);
 
            /* external references for interrupt handlers */
extern IOHNDLR();
extern EXTHNDLR();
 
            /* external references for context switching */
extern CSWITCH();
extern CSWITCH1();
 
           /* external reference for disabling interrupts */
extern disable_();
 
            /* external references for supplied functions */
extern SPT_();         /* resets timer */
extern breakpt_();     /* sets breakpoint in program */
 
                /* external reference for root */
extern root();
