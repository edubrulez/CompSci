/*  TDriver.c  --  Driver program to test table functions
 
    written by:  John Donaldson
    date:        September 5, 1995
 
    This program tests the table operations by creating a
    table, loading a set of opcode table records into it,
    making a series of sample retrievals, and finally printing
    a physical listing of the table contents.
 
    The program expects two command-line arguments:
    1.  The number of slots in the table.
    2.  The name of a data file containing opcode information.
                                                                */
#include "optab.h"
#include "table.h"
#include <stdio.h>
#include <stdlib.h>
 
static char* testcases[] = {"NEIN","LDDI","LCO","ADAL","PSHD","INSP",
                            "Q","RSH","LSH","LDDR","SWPB","EDUB",
                            "SACK","LLA","POPA","SBAR",0};
 
main(int argc,char**argv)
{
char **p;
int k,OptabSize;
TableRecord *tptr;
OpcodeData *dptr;
 
Table OpcodeTable;
 
/* Test validity of command-line arguments */
if(argc!=3){
  printf("Usage:  tdriver tablesize inputfile\n");
  exit(1);
}
if((OptabSize=atoi(argv[1]))<=0){
  printf("Table size must be a positive integer\n");
  exit(1);
}
 
/* Create an empty table               */
TCreate(&OpcodeTable,OptabSize);
 
/* Load data from opcode data file into the table */
LoadOpcodeTable(OpcodeTable,argv[2]);
 
/* Series of sample retrievals   */
printf("Trying test cases:\n");
for(p=testcases;*p!=0;++p){
  tptr=TRetrieve(OpcodeTable,*p);
  if(tptr==0)
    printf("Opcode %s not found\n",*p);
  else {
    dptr=tptr->data;
    printf("%-5s  %-4X  %d\n",*p,dptr->opcode,dptr->format);
    }
}
 
/* Display table contents in physical order */
printf("\nOpcode table in physical order:\n");
for(k=0,tptr=OpcodeTable.data;k<OpcodeTable.tsize;++k,++tptr)
  if(dptr=tptr->data)
   printf("%4d  %-5s  %-4X  %d\n",k,tptr->key,dptr->opcode,dptr->format);
 
}
 
 
