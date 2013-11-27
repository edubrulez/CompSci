/* Erick Nave
   Operating Systems
   Phase 4 -- Input and Output -- IO.H
 
   IO.h contains declarations for IO control. */
 
#define READER   1
#define WRITER   2
 
               /* type definition for CSW template */
typedef struct CSWbits {
           unsigned key       : 4;
           unsigned susp      : 1;
           unsigned logout    : 1;
           unsigned cc        : 2;
           unsigned CCWaddr   : 24;
           unsigned CheckBits : 16;
           unsigned ByteCt    : 16;
    } CSWtemp;
 
                  /* Type definition for I/O block */
typedef struct IOBlockType {
            int devaddr;           /* device address */
            int subsysID;          /* subsystem ID */
            int pin;               /* PIN of device handler proc */
            CSWtemp lastCSW;       /* CSW of last I/O operation */
            semaptr BlkHndlr;      /* sema to block dev handler */
    } IOBlock;
 
#define DTSIZE  3
extern IOBlock DevTable[DTSIZE];
extern int BadDevice;
 
           /* Type definition for contents of a device message */
typedef struct DeviceMessage {
            void *bufaddr;       /* buffer address of area for input */
            int reqcode;         /* type of request (r/w) */
            semaptr CallerSema;  /* addr of calling proc's I/O sema */
            void *sts;           /* addr of copy of CSW */
            char *procname;      /* addr of proc name of requestor */
            int blknum;          /* block number for disk reads */
    } DevMsg;
 
typedef DevMsg *DevMsgPtr;
#define DevMsgLen 24
 
              /* type definition for CCW template */
typedef struct CCWbits {
            unsigned opcode   : 8;
            unsigned DataAddr : 24;
            unsigned flags    : 8;
            unsigned          : 8;
            unsigned ByteCt   : 16;
    } CCWtemp;
 
typedef CCWtemp *CCWptr;
#define CCWlen 64
 
               /* type definition for Disk Address */
typedef struct DiskAddress {
            unsigned cylinder : 32;
            unsigned track    : 16;
            unsigned record   : 8;
            unsigned          : 8;
    } DiskAddr;
 
#define DiskAddrLen 64
 
               /* definitions for IO Device table slots */
#define CardRdr 0
#define Console 1
#define Disk    2
 
               /* external references for I/O functions */
extern void InitIO();
extern int read_(char*,void*,int);
extern int write_(char*,void*);
extern void CardHndlr();
extern void ConsHndlr();
extern void DiskHndlr();
extern void iohndlrc();
 
            /* external references for I/O routines provided */
extern int STARTIO(int,int*,int*);
extern int INITDEV_(int);
extern void GETSTS_(int,int*);
