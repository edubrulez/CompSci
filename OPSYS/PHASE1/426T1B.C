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
freeptr x[20],w,y,p;
int    i;
 
initmem_();
fsldump();
for (i=19;i>=0;i--)                /* allocate 20 blocks */
{
  x[i] = getmem_(i*50+20);
  printf("%06X \n",x[i]);
}
fsldump();
for (i=19;i>=0;i-=3)              /* release every third block */
  freemem_(x[i],i*50+20);
fsldump();
w = getmem_(620);
freemem_(x[9],470);
y = getmem_(690);
fsldump();
freemem_(y,690);
freemem_(x[5],270);
freemem_(x[8],420);
p=getmem_(0x310);
y=getmem_(320);
fsldump();
if(getmem_(0x3E0000)) /* test for oversized block */
  printf("No check for request too big\n");
freemem_(w,620);
freemem_(p,0x310);
freemem_(y,320);
fsldump();
freemem_(x[2],120);
for (i=11;i<20;i+=3)
  freemem_(x[i],i*50+20);
fsldump();
for (i=0;i<8;i+=3)
  freemem_(x[i],i*50+20);
fsldump();
for (i=12;i<20;i+=3)                /* free all blocks */
  freemem_(x[i],i*50+20);
fsldump();                       /* final dump */
 
}
