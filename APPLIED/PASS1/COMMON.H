/* Erick Nave
   Applied Systems Programming
   Programming Assignment 2 - Assembler Pass One
   Due Oct. 2
 
   Common.h contains the typedefs for OpcodeData and SymbolData for
     their respective tables.  It also contains the function prototypes
     for LoadOpcodeTable and ParseLine which are in common.c */
 
#ifndef COMMON_H_DEFINED
#define COMMON_H_DEFINED
#include "table.h"
 
         /* Definition for a single entry in the opcode table */
typedef struct {
  char mnemonic[5];  /* mnemonic */
  int opcode;        /* opcode associated with the mnemonic */
  int format;        /* format of the mnemonic/opcode */
} OpcodeData;
 
         /* Definition for a single entry in the symbol table */
typedef struct {
  char symbol[9];  /* symbol */
  unsigned value;  /* symbol's value */
  int type;        /* type of symbol */
} SymbolData;
 
                    /* Definition for an ITF line */
typedef struct {
  short locctr;      /* location counter */
  unsigned error;         /* error flag */
  char srcline[80];  /* source line */
} ITFline;
 
/* codes for symbol type */
#define ABS 1
#define REL 2
#define EXT 3
 
/* definition for error codes */
#define MULT_DEF_SYM 1
#define INVALID_LABEL 2
#define ILLEGAL_OPCODE 4
#define SYM_TAB_OF 8
 
/* definitions for directive strings */
#define dummystr "0"
#define endstr "END"
#define dsstr "DS"
#define equstr "="
#define extstr "EXT"
 
extern void LoadOpcodeTable(Table,char*);
 
extern void ParseLine(char*,char**,char**,char**);
 
extern void upper(char*);
 
extern void Pass1(char*,Table,Table);
 
/* extern void Pass2(); */
 
#endif
