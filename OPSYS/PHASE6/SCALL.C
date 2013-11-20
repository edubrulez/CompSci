/*------------------------------------------------------------------*/
/*                            scall.c                               */
/*   This source file contains c functions to be used as entry      */
/*   points for system calls.                                       */
/*------------------------------------------------------------------*/
 
#include "scall.h"
#include <stdarg.h>
 
extern int svc_();
 
/*---------------------------------------------------*/
/* lines  -- library front-end routine for lines_    */
/*---------------------------------------------------*/
 
void lines(char *message)
{
svc_(LINES,message);
}
 
/*-----------------------------------------------------*/
/* snap     -- library front-end routine for snap_     */
/*-----------------------------------------------------*/
 
void snap(void *start, void *end)
{
svc_(SNAP,start,end);
}
 
 
/*---------------------------------------------------*/
/* breakpt - library front-end routine for breakpt_  */
/*---------------------------------------------------*/
 
void breakpt(int breaknum)
{
svc_(BREAKPT,breaknum);
}
 
/*---------------------------------------------------*/
/* getmem -- library front-end routine for getmem_   */
/*---------------------------------------------------*/
 
void *getmem(int size)
{
return (void *) svc_(GETMEM,size);
}
 
/*-----------------------------------------------------*/
/* freemem  -- library front-end routine for freemem_  */
/*-----------------------------------------------------*/
 
void freemem(void *addr,int size)
{
svc_(FREEMEM,addr,size);
}
 
/*--------------------------------------------------*/
/* create -- library front-end routine for create_  */
/*--------------------------------------------------*/
 
int create(char *name,void *psw,void*ustack,int argc,void *args)
{
return svc_(CREATE,name,psw,ustack,argc,args);
}
 
/*---------------------------------------------------*/
/* destroy -- library front-end routine for destroy_ */
/*---------------------------------------------------*/
 
void destroy(int termination_code)
{
svc_(DESTROY,termination_code);
}
 
/*--------------------------------------------------*/
/* p   -- library front-end routine for p_          */
/*--------------------------------------------------*/
 
int p(void*sem)
{
return svc_(P,sem);
}
 
/*--------------------------------------------------*/
/* v -- library front-end routine for v_            */
/*--------------------------------------------------*/
 
int v(void*sem)
{
return svc_(V,sem);
}
 
/*--------------------------------------------------*/
/* getsem -- library front-end routine for allsem_  */
/*--------------------------------------------------*/
 
void *getsem(int sem_value)
{
return (void*) svc_(GETSEM,sem_value,0);
}
 
/*---------------------------------------------------*/
/* freesem -- library front-end routine for freesem_ */
/*---------------------------------------------------*/
 
int freesem(void*sem)
{
return svc_(FREESEM,sem);
}
 
/*--------------------------------------------------*/
/* send  -- library front-end routine for send_     */
/*--------------------------------------------------*/
 
int send(int topin,void *message,int length)
{
return svc_(SEND,topin,message,length);
}
 
/*---------------------------------------------------*/
/* receive -- library front-end routine for receive_ */
/*---------------------------------------------------*/
 
int receive(void *buffer,int length)
{
return svc_(RECEIVE,buffer,length);
}
 
/*--------------------------------------------------*/
/* read  -- library front-end routine for read_     */
/*--------------------------------------------------*/
 
int read(void *devid,void *buffer,int block)
{
return svc_(READ,devid,buffer,block);
}
 
/*---------------------------------------------------*/
/* write -- library front-end routine for write_     */
/*---------------------------------------------------*/
 
int write(void *devid,void *buffer)
{
return svc_(WRITE,devid,buffer);
}
 
/*---------------------------------------------------*/
/* cpcmd -- library front-end routine for cpcmd_     */
/*---------------------------------------------------*/
 
int cpcmd(int command,int mode)
{
return svc_(CPCMD,command,mode);
}
 
/*-----------------------------------------------------*/
/* _printf -- library front-end routine for printf     */
/*-----------------------------------------------------*/
 
int _printf(char * fmt,...)
{
/*
va_list args;
int a[4],k;
 
va_start(args,fmt);
for(k=0;k<4;++k)
  a[k]=va_arg(args,int);
va_end(args);
 
return svc_(PRINTF,fmt,a[0],a[1],a[2],a[3]);
*/
return svc_(PRINTF,fmt,(&fmt)[1],(&fmt)[2],(&fmt)[3],(&fmt)[4]);
}
