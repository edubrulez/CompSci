#include <string.h>
#include "scall.h"
#include "memory.h"
 
#pragma inline memcmp
#pragma inline memcpy
#define INTSIZE 4
#define LOOPLIM 600
#define ODD(i) ( (i) & 1)
 
int producer();
int summer();
int ptester();
int semtest1();
 
int psum,npsum;
 
root()
   {
   char mbuffer1[10],mbuffer2[10];
   int ecode;
   int y,z;
   int pins[6];
   int sender,sender1,sender2;
   int buffer;
   int temp,mypin;
   char tbuf[20];
   int testerparms[3];
   int producerparms[4]={LOOPLIM,0,0,0};
 
   unsigned int  producrpsw[2] = {0x03090000,producer};
   unsigned int  ptesterpsw[2] = {0x03090000,ptester};
   unsigned int  summerpsw[2] = {0x03090000,summer};
   unsigned int  semtest1psw[2] = {0x03090000,semtest1};
 
   /*  Check error detection */
 
   if (send(13,0,4)==0)/* This is an error check.  It should fail. */
      {
         lines("***SEND failed to return proper error code");
         return(-7);
      }
 
   /*  Create 2 child processes for summations */
   testerparms[1] = pins[3] = create("SUMMER1 ",summerpsw,0,0,0);
   testerparms[2] = pins[4] = create("SUMMER2 ",summerpsw,0,0,0);
 
   send(pins[3],"",0);              /* send null message to summer */
   send(pins[4],"",0);              /* send null message to summer */
 
   /* wait for response from both summers */
   sender1=receive(&mypin,INTSIZE);
   sender2=receive(&temp,INTSIZE);
   if(sender1+sender2 != pins[3]+pins[4])
      {
      lines("***Messages should have come from summers");
      return(-2);
      }
   if(sender1!=pins[3]){
      lines("***Messages may have been received out of order");
      }
   if(temp!=mypin){
      lines("***Messages from summers should have been identical");
      return(-3);
      }
 
   /* Check basic sending capability */
 
   if(send(pins[3],"MESSAGE 1",10)!=0){   /* send message to summer */
     _printf("Bad return code sending message 1");
     return(-4);
     }
   if(send(pins[4],"MESSAGE 2",10)!=0){   /* send message to summer */
     _printf("Bad return code sending message 2");
     return(-5);
     }
 
   /* wait for response from both summers */
   sender1=receive(mbuffer1,10);
   sender2=receive(mbuffer2,10);
   ecode=0;
   if(sender1==pins[3]){
     if(memcmp(mbuffer1,"MESSAGE 1",10)!=0){
       _printf("Error in send and receive with summer 1");
       _printf("Message received was %s",mbuffer1);
       ecode= -6;
       }
     if(memcmp(mbuffer2,"MESSAGE 2",10)!=0){
       _printf("Error in send and receive with summer 2");
       _printf("Message received was %s",mbuffer2);
       ecode= -7;
       }
     if(sender2!=pins[4]){
       _printf("Error in sender2 return code at point A");
       ecode= -8;
       }
     }
   else if(sender1==pins[4]){
     if(memcmp(mbuffer2,"MESSAGE 1",10)!=0){
       _printf("Error in send and receive with summer 1");
       _printf("Message received was %s",mbuffer1);
       ecode= -9;
       }
     if(memcmp(mbuffer1,"MESSAGE 2",10)!=0){
       _printf("Error in send and receive with summer 2");
       _printf("Message received was %s",mbuffer2);
       ecode= -10;
       }
     if(sender2!=pins[3]){
       _printf("Error in sender2 return code at point B");
       ecode= -11;
       }
     }
   else {
     _printf("Bad return code %d in first receive",sender1);
     _printf("Return code from second receive was %d",sender2);
     ecode= -12;
     }
   if(ecode != 0)
     return ecode;
 
   /* End of basic sending capability check */
   _printf("End of basic send and receive tests");
 
   pins[5] = create("SEMTEST1",semtest1psw,0,0,0);
   testerparms[0]=mypin;
   producerparms[1]=mypin;
   producerparms[2]=pins[1]=
      create("PTESTER1",ptesterpsw,0,3,testerparms);
   producerparms[3]=pins[2]=
      create("PTESTER2",ptesterpsw,0,3,testerparms);
   pins[0] = create("PRODUCER",producrpsw,0,4,producerparms);
 
  /*  Now, root waits until its children are done processing.  It
      expects a message from each of them. */
 
  y=2; z=2;
  while (z>0)
     {
    if((sender=receive(&buffer,INTSIZE))==pins[1] || sender==pins[2])
            {
               if (memcmp("DONE",&buffer,4))
                  {
                     lines("***Bad message from tester");
                     return(-4);
                  }
               if (!(--y))
                  {
                     /* When ptester1 and ptester2 are done,
                        send -1 to summer1 and summer2 as an
                        "end-of-data" signal */
                     int m1 = -1;
 
                     send(pins[3],&m1,INTSIZE);
                     send(pins[4],&m1,INTSIZE);
                  }
            }
         else if (sender == pins[3])
            /*  Message from summer of primes */
            {
               z--;
               psum=buffer;
            }
         else if (sender == pins[4])
            /*  Message from summer of non-primes */
            {
               z--;
               npsum=buffer;
            }
         else if (sender == pins[0])
            {
               if (memcmp("DONE",&buffer,4))
                  {
                     lines("***Bad message from producer");
                     return(-5);
                  }
            }
         else
            {
               lines("***Unknown sender");
               return (-6);        /* error */
            }
      }
  _printf("psum = %d (%x)  npsum = %d (%x)",psum,psum,npsum,npsum);
  send(pins[5],0,0);
  _printf("Root process is terminating");
}
 
/*  Producer -- This process generates the sequence of integers in the
                form "n*n+1" where n ranges from 1 to a predefined
                loop limit.  It sends these values alternately to two
                processes specified by its parent. */
 
producer(int looplim,int parent,int test1pin,int test2pin)
{
   int m,i;
 
   for (i = 1; i <= looplim; i++){
      m = i*i+1;
      send(ODD(i)? test1pin : test2pin ,&m,INTSIZE);
      }
   m=-1;
   send(test1pin,&m,INTSIZE);   /* Send end-of-data indicator */
   send(test2pin,&m,INTSIZE);   /* Send end-of-data indicator */
   send(parent,"DONE",4);      /* Tell parent I'm done */
}
 
/*  Ptester -- This process receives integer data.
               Each integer received is tested for primality.
               Prime numbers are sent to a specified process and
               nonprimes are sent to another process. */
 
ptester(int parent,int primedest,int nonprimedest)
{
int x;
 
while(receive(&x,INTSIZE),x>0){
    send(prime(x)?primedest:nonprimedest,&x,INTSIZE);
}
 
send(parent,"DONE",4);        /* Tell parent I'm done */
}
 
/* prime -- Function to determine primality of a given integer
            Input:    n -- integer to be tested
            Returns:  0 if nonprime
                      1 if prime */
 
int prime(int n)
{
   int divisor;
 
   divisor = 2;
   while (divisor * divisor <= n)
      {
         if ((n%divisor) == 0)
         return(0);
         divisor++;
      }
   return(1);
}
 
/*  Summer -- This process receives a sequence of integer data values
              and computes their sum.  The sum is then sent in a
              message to its parent. */
 
summer()
{
char testbuffer[10];
int sum=0,x,parent;
int rc;
/* get pin of parent and send back parent's pin */
parent=receive(0,0);
rc=send(parent,&parent,INTSIZE);
if(rc!=0)
   lines("Message to root was lost");
/*  receive another message and send it back  */
if(receive(testbuffer,10)!=parent){
  _printf("Bad return code from receive in summer");
  return -1;
  }
if(send(parent,testbuffer,10)!=0){
  _printf("Bad return code from send in summer");
  return -1;
  }
 
while(receive(&x,INTSIZE),x>0){/* Receive input value  */
   sum += x;                   /* Add it to sum        */
   }
 
send(parent,&sum,INTSIZE);    /* Send result to parent */
}
 
semtest1()
{
   int semtest2(),semtest3();
   int child1,child2,child3;
   int root;
   unsigned int  semtest2psw[2] = {0x03090000,semtest2};
   unsigned int  semtest3psw[2] = {0x03090000,semtest3};
   void*  sem;
   freeptr q;
 
   sem = getsem(0);
 
   /* create a child and pass the semaphore address to it */
   child1=create("SEMTEST2",semtest2psw,0,1,&sem);
   child2=create("SEMTEST3",semtest3psw,0,1,&child1);
 
   /*  wait for a while  */
   root=receive(0,0);
   freesem(sem);
   send(child2,0,0);
   receive(0,0);
   _printf("Semtest1 is done");
   _printf("Free space list:");
   for(q=FSLPTR;q!=0;q=q->next)
     _printf("%x  %x  %x",q,q->size,q->next);
}
semtest2(void *sem)
{
   if (freesem(sem)==0)
      {
         lines("***Semtest2 freed a semaphore it does not own");
         return(-3);
      }
   if(p(sem)!= -1)
     _printf("Semtest2 received unexpected error code from P");
   _printf("Semtest2 is done");
}
semtest3(int sibling)
{
   int parent;
   if(send(sibling,"Hello",6)!= -1)
     _printf("Semtest3 received unexpected error code from send");
   parent=receive(0,0);
   send(parent,0,0);
}
