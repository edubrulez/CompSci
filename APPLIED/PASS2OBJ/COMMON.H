/* Erick Nave
   Applied Systems Programming
   Programming Assignment 2 - Assembler Pass One
   Due Oct. 2
 
   Common.h contains the typedefs for OpcodeData and SymbolData for
     their respective tables.  It also contains the function prototypes
     for LoadOpcodeTable and ParseLine which are in common.c
 
   Programming Assignment 3 -  Pass 2 with listing file
     Add more error conditions and prototype for expression evaluator
 
   Programming Assignment 4 - object file
     Add union of object file structures           */
 
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
  char type;        /* type of symbol */
} SymbolData;
 
                    /* Definition for an ITF line */
typedef struct {
  short locctr;      /* location counter */
  unsigned error;         /* error flag */
  char srcline[80];  /* source line */
} ITFline;
 
            /* codes for symbol type */
#define ABS 'A'
#define REL 'R'
#define EXT 'D'
#define DXEXT 'E'
 
                /* definition for error codes */
#define MULT_DEF_SYM 1
#define INVALID_LABEL 2
#define ILLEGAL_OPCODE 4
#define SYM_TAB_OF 8
#define UNDEF_SYM 16
#define ILL_EXT_REF_EXPR 32
#define ILL_EXPR 64
#define OPERAND_MISS 128
#define REL_OUT_OF_RANGE 256
#define LOC_OUT_OF_RANGE 512
#define BAD_SYM_DX 1024
#define WRONG_EXP_TYPE 2048
#define OVERFLOW 4096
#define UNEXPECTED_LABEL 8192
 
             /* definitions for directive strings */
#define dummystr "0"
#define endstr "END"
#define dsstr "DS"
#define equstr "="
#define extstr "EXT"
#define dxstr "DX"
#define dcstr "DC"
 
        /* definition for maximum # of words in an txt line */
#define maxwords 36
 
              /* definition for an object record */
typedef union {
         /* definition for header record */
  struct HdrRecord {
    char rectype[4];  /* "HDR\0" */
    short proglen;    /* program length */
   } hdr;
 
        /* definition for define record */
  struct DefRecord {
    char rectype[4];  /* "DEF\0" */
    char symbol[8];   /* external symbol name */
    short symaddr;    /* address of symbol */
   } def;
 
       /* definition of text record */
  struct TxtRecord {
    char rectype[4];       /* "TXT\0" */
    short txtaddr;         /* address of txt */
    short wordct;          /* word count */
    short code[maxwords];  /* machine code */
   } txt;
 
       /* definition of modification record */
  struct ModRecord {
    char rectype[4];  /* "MOD\0" */
    char symbol[8];   /* symbol name to be modified */
    short symaddr;    /* address of symbol */
   } mod;
 
       /* definition of end record */
  struct EndRecord {
    char rectype[4];  /* "END\0" */
    short flag;       /* 1 = starting addr,  0 = no starting addr */
    short startaddr;  /* starting address */
   } end;
 
       /* definition of init string */
  char init[80];
 } objrec;
 
extern void LoadOpcodeTable(Table,char*);
 
extern void ParseLine(char*,char**,char**,char**);
 
extern void upper(char*);
 
extern void EvalExpr(char*,Table,int*,char*,unsigned*);
 
extern int Pass1(char*,Table,Table);
 
extern void Pass2(char*,Table,Table,int);
 
#endif
