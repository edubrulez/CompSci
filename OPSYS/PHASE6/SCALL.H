/*--------------------------------*/
/* Supervisor Interrupt ID Codes  */
/*--------------------------------*/
 
#define LINES     0x01      /* Display a line on the console        */
#define SNAP      0x02      /* Display registers and storage        */
#define GETMEM    0x03      /* Get a block of memory                */
#define FREEMEM   0x04      /* Free a block of memory               */
#define CREATE    0x05      /* Create a process and make it ready   */
#define DESTROY   0x06      /* Abolish running process from system  */
#define P         0x07      /* Perform P(S) operation               */
#define V         0x08      /* Perfrom V(S) operation               */
#define GETSEM    0x09      /* Allocate system SEMAPHORE structure  */
#define FREESEM   0x0A      /* Return a system SEMAPHORE structure  */
#define SEND      0x0B      /* Send an inter-process message        */
#define RECEIVE   0x0C      /* Receive an inter-process message     */
#define READ      0x0D      /* Read a record                        */
#define WRITE     0x0E      /* Write a record                       */
#define BREAKPT   0x0F      /* Suspend the VM and enter CP          */
#define CPCMD     0x10      /* Issue a CP command                   */
#define PRINTF    0x11      /* Formatted Print */
 
/*--------------------------------------------------*/
/* functions                                        */
/*--------------------------------------------------*/
 
extern void lines(char *);
extern void snap(void *,void *);
extern void breakpt(int);
extern void *getmem(int);
extern void freemem(void *,int);
extern int create(char *,void *,void*,int,void *);
extern void destroy(int);
extern p(void*);
extern v(void*);
extern void *getsem(int);
extern int freesem(void*);
extern int send(int,void *,int);
extern int receive(void *,int);
extern int read(void *,void *, int);
extern int write(void *,void *);
extern int cpcmd(int,int);
extern int _printf(char*,...);
