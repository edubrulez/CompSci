/*------------------------------------------------------------------*/
/*                           memory.h                               */
/*   This header contains declarations for memory management        */
/*------------------------------------------------------------------*/
 
 /* Type definitions      */
struct freenode {
    int      size;
    struct   freenode *next;
    } ;
typedef struct freenode freeblk;
typedef freeblk *freeptr;
 
 /* Global variable definition */
extern freeptr FSLPTR;
 
 /* Macro definition */
#ifndef ENDMEM
#define ENDMEM 0x300000
#endif
#ifndef STARTMEM
#define STARTMEM (int) endos
#endif
 
 /* Function definitions  */
extern void initmem_();
extern int  endos();
extern void *getmem_(int size);
extern void freemem_(void*addr,int size);
