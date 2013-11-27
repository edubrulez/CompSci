#include "memory.h"
#include "process.h"
#ifndef A
#define A 0x10000
#endif
#ifndef B
#define B 0x8000
#endif
 
/*
  ctr1, ctr2, ctr3, ctr4, and ctr5 are global variables initialized to
  0.  They are repeatedly incremented by the 5 child processes.
 */
int  ctr1=0,ctr2=0,ctr3=0,ctr4=0,ctr5=0;
int  pin[5];
int  parm1[]={A,B};
int  parm2[]={B,A};
 
int root();
int prog1();
int prog2();
int prog3();
int prog4();
int prog5();
 
unsigned int  prog1psw[2] = {0x03080000,prog1};
unsigned int  prog2psw[2] = {0x03080000,prog2};
unsigned int  prog3psw[2] = {0x03080000,prog3};
unsigned int  prog4psw[2] = {0x03080000,prog4};
unsigned int  prog5psw[2] = {0x03080000,prog5};
 
/*
  The root process creates four child processes, then terminates
  without waiting for the children to finish.
  */
root()
{
void *ustp = getmem_(0x1000);
void *p=getmem_(0x2000);
pin[0] = create_("PROCESS1",prog1psw,0,2,parm1);
pin[1] = create_("PROCESS2",prog2psw,0,1,parm1);
pin[2] = create_("PROCESS3",prog3psw,0,2,parm2);
pin[3] = create_("PROCESS4",prog4psw,ustp,2,parm1);
pin[4] = create_("PROCESS5",prog5psw,0,2,parm2);
freemem_(p,0x2000);
destroy_(0);
}
 
 
/*
  prog1 adds loop1 to ctr2, and then adds loop2 to ctr1.
  ctr1 and ctr2 are global variables.
  */
prog1(int loop1,int loop2)
{
int i,t;
 
for(i=0;i<loop1;i++)
    {
    t = ctr2;
    t++;
    ctr2=t;
    }
for(i=0;i<loop2;i++)
    {
    ctr1++;
    }
destroy_(0);
}
 
/*
  prog2 adds maxloop to ctr2 by repeated incrementing.
  */
prog2(int maxloop)
{
int t;
 
while(maxloop--)
    {
    t = ctr2;
    t++;
    ctr2=t;
    }
destroy_(0);
}
 
/*
  prog3 adds loop1 to ctr3, adds loop2 to ctr1, and then adds loop1
  to ctr3.
  */
prog3(int loop1,int loop2)
{
int i,t;
 
for(i=0;i<loop1;i++)
    {
    t = ctr3;
    t++;
    ctr3=t;
    }
for(i=0;i<loop2;i++)
    {
    ctr1++;
    }
for(i=0;i<loop1;i++)
    {
    ctr3++;
    }
destroy_(0);
}
 
/*
  prog4 adds loop2 to ctr4 and adds loop1 to ctr2.
  */
prog4(int loop1,int loop2)
{
int t;
 
while(loop2--)
    {
    t = ctr4;
    t++;
    ctr4=t;
    }
while(loop1--)
  ctr2++;
destroy_(0);
}
 
/*
  prog5 adds lp1 to ctr5 and adds lp2 to ctr1.
  */
prog5(int lp1,int lp2)
{
int i,t;
 
for(i=0;i<lp1;i++)
    {
    t = ctr5;
    t++;
    ctr5=t;
    }
for(i=0;i<lp2;i++)
    {
    ctr1++;
    }
destroy_(0);
}
 
