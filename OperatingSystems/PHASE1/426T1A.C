#include <stdio.h>
#include "memory.h"
 
int dumpno=0;
 
/********************************************************/
/*  fsldump  -- dumps contents of free space list to    */
/*              standard output.                        */
/*  includes:   stdio.h, memory.h                       */
/*  externals:  FSLPTR                                  */
/********************************************************/
fsldump()
{
freeptr mptr;
 
printf("\n\nCurrent contents of free space list: dump no %d\n",++dumpno);
printf("  ADDR   LENGTH   NEXT\n");
mptr = FSLPTR;
do {
  printf(" %06X  %06X  %06X\n",
     mptr,mptr->size,mptr->next);
  mptr=mptr->next;
} while (mptr != NULL);
}
 
/********************************************************/
/*  fillblock -- completely fills in a block of memory  */
/*               with a given character.                */
/********************************************************/
fillblock(char*blockptr,int len,char fillchar)
{
char *p;
 
for(p=blockptr ; p<blockptr+len ; p++)
  *p = fillchar;
}
 
/********************************************************************/
/*  main program -- to test the memory management routines for      */
/*                  operating systems assignment one.  The program  */
/*                  makes a series of calls to initmem_, getmem_,     */
/*                  and freemem_.  It uses fsldump to display the    */
/*                  contents of the free space list several times.  */
/*                  The first and last dumps should be identical,   */
/*                  with one block of free space.                   */
/*                                                                  */
/*  includes:   stdio.h, memory.h                                   */
/*  externals:  FSLPTR                                              */
/********************************************************************/
main()
{
char *v,*w,*x,*y,*z;
 
initmem_();
fsldump();
v=getmem_(0x880);
fillblock(v,0x880,'V');          /* Fill in allocated block  */
fsldump();
w=getmem_(0x2000);
fillblock(w,0x2000,'W');         /* Fill in allocated block  */
fsldump();
x=getmem_(0x600);
fillblock(x,0x600,'X');          /* Fill in allocated block  */
fsldump();
y=getmem_(0x5000);
fillblock(y,0x5000,'Y');         /* Fill in allocated block  */
fsldump();
z=getmem_(0x180);
fillblock(z,0x180,'Z');          /* Fill in allocated block  */
fsldump();
freemem_(w,0x2000);               /* no combine               */
fsldump();
freemem_(z,0x180);                /* combine with next block  */
fsldump();
freemem_(x,0x600);                /* combine with prior block */
fsldump();
freemem_(y,0x5000);               /* 3-way combine            */
fsldump();
freemem_(v,0x880);
fsldump();
}
