/*  Erick Nave
    Applied Systems Programming
    Programmming Assignment 2 - MACASM.C
 
    Macasm.c is the main driver for passes 1 and 2 of the assembler
      it expects a filename as a command line argument. It creates
      the opcode and symbol tables.  It calls the function to load the
      opcode table.  It then calls pass 1 and pass 2.
                                                                */
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
 
#define opfile "opcode.data"
 
/*extern Pass2();*/
 
Table SymbolTable;
   /* Symbol Table */
 
main(int argc,char**argv)
{
 Table OpcodeTable;
   /* Opcode Table */
 int proglen;
   /* program length returned from Pass 1 */
 
              /* Check for proper command line arguments */
 if(argc != 2)
  {
   printf("Usage:  macasm <source file name>\n");
   exit(1);
  }
 
                    /* Create Opcode and SymbolTables */
 TCreate(&SymbolTable,199);
 TCreate(&OpcodeTable,103);
 
                  /* Load opcode table using opcode.data */
 LoadOpcodeTable(OpcodeTable, opfile);
 
                      /* call pass 1 of assembler */
 proglen = Pass1(argv[1], OpcodeTable, SymbolTable);
 
                      /* call pass 2 of assembler */
 Pass2(argv[1], OpcodeTable, SymbolTable, proglen);
}
 
 
