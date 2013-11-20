#include "scall.h"
#include "memory.h"
 
extern void *MEMWAIT;
 
void *s1,*s2,*s3,*s4,*s5,*synch,*arrsem;
int  ctr1=0,ctr2=0,ctr3=0,ctr4=0;
int  parr1[3] = {256,0x3000,0x800};  /* Parameters to be passed from
                                        root to processes A and B  */
void *memarr[256];
int  pin[8];
 
int root();
int proga();
int progb();
int progc();
int prog1();
int prog2();
int prog3();
int prog4();
int prog5();
 
unsigned int  progapsw[2] = {0x03080000,proga};
unsigned int  progbpsw[2] = {0x03080000,progb};
unsigned int  progcpsw[2] = {0x03080000,progc};
unsigned int  prog1psw[2] = {0x03080000,prog1};
unsigned int  prog2psw[2] = {0x03080000,prog2};
unsigned int  prog3psw[2] = {0x03080000,prog3};
unsigned int  prog4psw[2] = {0x03080000,prog4};
unsigned int  prog5psw[2] = {0x03080000,prog5};
 
int looplim1 = 0x600;
int looplim2 = 0x500;
int looplim3 = 0x480;
 
root()
{
int    j;
freeptr q;
 
/* **** START OF BASIC ERROR CHECKING **** */
 
if (freesem(0) == 0)
    {
    lines("*** freesem failed error check");
    return(-1);
    }
 
arrsem = getsem(1);
lines("***If no line follows this then p_ or getsem_ has failed");
p(arrsem);
lines("***Basic p_ functions");
if (freesem(arrsem))
    {
    lines("*** freesem_ has failed");
    return(-1);
    }
 
arrsem = getsem(0);
lines("***If no line follows this then v_ has failed");
v(arrsem);
lines("***Basic v_ functions");
lines("***If no line follows this then p_ has failed");
p(arrsem);
lines("***Basic p_ functions");
if (freesem(arrsem))
    {
    lines("*** freesem_ has failed");
    return(-1);
    }
 
if (freesem(MEMWAIT) ==0)
    {
    lines("*** freesem_ has failed - MEMWAIT was freed");
    return(-1);
    }
 
if(v((void*)0x3000)==0)
  lines("*** V did not validate semaphore ***");
 
if(p((void*)0x3000)!= -1)
  lines("*** P did not validate semaphore ***");
 
/* **** end of basic error checking **** */
lines("*** end of basic error checking");
 
arrsem = getsem(0);
synch = getsem(0);
 
s1 = getsem(1);
s2 = getsem(1);
s3 = getsem(1);
s4 = getsem(1);
s5 = getsem(1);
create("PROCESSA",progapsw,0,3,parr1);
create("PROCESSB",progbpsw,0,2,parr1);
create("PROCESSC",progcpsw,0,1,&s5);
pin[0] = create("PROCESS1",prog1psw,0,1,&looplim1);
pin[1] = create("PROCESS2",prog2psw,0,0,0);
pin[2] = create("PROCESS3",prog3psw,0,1,&looplim2);
pin[3] = create("PROCESS4",prog4psw,0,0,0);
pin[4] = create("PROCESS5",prog5psw,0,1,&looplim1);
for (j=0;j<10;j++)
  p(synch);
freesem(arrsem);
freesem(s1);
freesem(s2);
freesem(s3);
freesem(s4);
freesem(s5);
freesem(synch);
_printf("Everything is done");
_printf("Last value in memarr is %x",memarr[255]);
_printf("Counter values are %x %x %x %x",ctr1,ctr2,ctr3,ctr4);
_printf("Free space list:");
for(q=FSLPTR;q!=0;q=q->next)
  _printf("%x  %x  %x",q,q->size,q->next);
}
 
progc(void*sem)
{
if(p(sem)!= 0)
  lines("*** Error in good return code from P ***");
if(p(sem)!= -1)
  lines("*** Error in bad return code from P ***");
}
 
proga(int nblox,int blocksize,int alignment)
{
int i;
 
if(alignment != 0x800){
  lines("!!! If this message appears, there is an error in");
  lines("!!! passing parameters to new processes !!!");
  }
for (i=0;i<nblox;i++)
  {
  memarr[i] = getmem(blocksize,alignment);
  v(arrsem);
  }
lines("v synch");
v(synch);
lines("should call kill");
}
 
progb(int nblox,int blocksize)
{
int i;
 
for(i=0;i<nblox;i++)
  {
  p(arrsem);
  freemem(memarr[i],blocksize);
  }
v(synch);
}
 
prog1(int maxloop)
{
int i,t;
int subsize = 2*maxloop;
 
pin[5] = create("PROCESS6",prog3psw,0,1,&subsize);
for(i=0;i<maxloop;i++)
    {
    p(s2);
    t = ctr2;
    t++;
    ctr2=t;
    v(s2);
    }
for(i=0;i<maxloop;i++)
    {
    p(s1);
    ctr1++;
    v(s1);
    }
v(synch);
}
 
prog2()
{
int i,t;
 
pin[6] = create("PROCESS7",prog4psw,0,0,0);
pin[7] = create("PROCESS8",prog5psw,0,1,&looplim3);
for(i=0;i<2*looplim3;i++)
    {
    p(s2);
    t = ctr2;
    t++;
    ctr2=t;
    v(s2);
    }
v(synch);
}
 
prog3(int loopmax)
{
int i,t;
 
for(i=0;i<loopmax;i++)
    {
    p(s3);
    t = ctr3;
    t++;
    ctr3=t;
    v(s3);
    }
for(i=0;i<loopmax;i++)
    {
    p(s1);
    p(s3);
    ctr3++;
    ctr1++;
    v(s1);
    v(s3);
    }
v(synch);
destroy(1);    /* Just a test to see if parameter to destroy is
                  handled correctly  */
}
 
prog4()
{
int i,t;
 
for(i=0;i<looplim3;i++)
    {
    p(s4);
    t = ctr4;
    t++;
    ctr4=t;
    v(s4);
    }
for(i=0;i<looplim3;++i)
    {
    p(s2);
    ctr2++;
    v(s2);
    }
v(synch);
}
 
prog5(int maxloop)
{
int i,t;
 
for(i=0;i<maxloop;i++)
    {
    p(s2);
    t = ctr4;
    t++;
    ctr4=t;
    v(s2);
    }
for(i=0;i<maxloop;i++)
    {
    p(s1);
    ctr1++;
    v(s1);
    }
v(synch);
}
