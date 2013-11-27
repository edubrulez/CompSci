/* Erick Nave
   Operating Systems
   Phase 3 -- Semaphores and SVC's
 
   Sema.h contains the declarations for Semaphores and SVC */
 
#define MAXSEMAS  8
 
                /* Type definitions for Semaphore */
typedef struct semaphore {
            char code[4];
            int ctr;
            Que SQ;
            PCBptr owner;
 } sema;
 
typedef sema *semaptr;
 
             /* external references for semaphore routines */
extern semaptr getsem_(int,PCBptr);
extern int freesem_(semaptr);
extern int P_(semaptr);
extern int V_(semaptr);
 
              /* external references for svc_ and kill */
extern SVC_();
extern KILL();
 
        /* external declarations for table and memory semaphores */
extern semaptr PTSEM;
extern semaptr MEMWAIT;
