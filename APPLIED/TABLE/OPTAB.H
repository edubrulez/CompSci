#ifndef OPTAB_H_DEFINED
#define OPTAB_H_DEFINED
#include "table.h"
 
typedef struct {       /* Definition for a single entry */
  char mnemonic[5];    /* in the opcode table           */
  int opcode;
  int format;
} OpcodeData;
 
extern void LoadOpcodeTable(Table,char*);
 
#endif
