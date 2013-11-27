/* Erick Nave
   Operating Systems
   Phase 6 -- Job Control -- job.h
 
   job.h contains definitions for job control. */
 
              /* union typedef for IBM 370 object records */
typedef union {
                 /* structure definition for ESD record */
    struct ESDrec {
        char two;
        char rectype[3];          /* record type */
        char a[12];
        char name[8];             /* job name */
        char b[4];
        unsigned         : 8;
        unsigned len     : 24;    /* program length */
        char c[40];
      } esd;
 
                  /* structure definition for TXT record */
    struct TXTrec {
        char two;
        char rectype[3];        /* record type */
        unsigned         : 8;
        unsigned offset  : 24;  /* offset of 1st byte in data record */
        unsigned         : 16;
        unsigned ByteCt  : 16;  /* # of bytes of text in data record */
        char ignore[4];
        char data[56];          /* data record */
      } txt;
 
                  /* structure definition for END record */
    struct ENDrec {
        char two;
        char rectype[3];        /* record type */
        unsigned         : 8;
        unsigned offset  : 24;  /* offset of 1st instr to execute */
        char a[64];
      } end;
 
    char init[72];
 
  } objrec;
extern objrec obj;
                 /* structure definition for job block */
typedef struct JobBlock {
            char name[8];     /* job name */
            int inuse;        /* block usage marker */
            void *region;     /* memory region for job */
            int len;          /* length of the region */
            int procs;        /* # of processes the job owns */
   } job;
 
#define MaxJobs 16
extern job JobTable[MaxJobs];
 
             /* external reference for Status Key semaphore */
extern semaptr SKsem;
extern semaptr ReaderEmpty;
 
             /* external reference for job control function */
extern void jobcntrl();
 
           /* external reference for sske machine instruction */
extern SSKEASM();
 
          /* external reference for abnormal termination function */
extern void abend();
 
                /* external reference for status key */
extern int StKey;
