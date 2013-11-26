/* Erick Nave
   Survey of Programming Languages
   Program 3 - part.c
   Start 3-11-94
   Last Update 3-29-94

  part.c uses a list ADT (glist.h) for an inventory of part records.  It begins
    by reading a data file to build preliminary master and supplier lists.
    It then reads a series of commands from stdin and processes them. Commands
    include additions to quantity, displaying specific parts, inserting parts,
    displaying a supplier list (or lists) or master list, removing parts, and  
    exiting with or without saving the updated list to the data file.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "glist.h"

void free(void *); /* clarifies meaning of free for apply functions */

struct part{
   char partno[9]; /* part number in the form XXNNXNNN*/
   char desc[25];  /* part description */
   int quantity;   /* quantity on hand */
   int supplier;   /* suppiler code */
};

typedef struct part parttype;
typedef struct part *partptr;

void getinv(glist m, glist *s, char *f, int MaxSuppNum)
/* getinv obtains preliminary inventory information from the file f.  It
      reads a line from the file and parses the string into its proper 
      components based on struct part.  Then the data is inserted into the
      master (m) and correct supplier (s) list. */
{
 FILE *fptr; /* file pointer */
 partptr p; /* ptr to struct part */
 char st[50]; /* string read from file */
 int okm, oks; /* return values from insert */
 okm = oks = 0;
 if ((fptr = fopen(f, "r")) == NULL)
   {
    printf("Unable to open %s for input.\n", f);
    exit(1);
   }
 else
   {
    printf("Obtaining inventory information..........\n");
    while ((fgets(st, 100, fptr)) != NULL)
      {
       p = (partptr)malloc(sizeof(parttype));   
       strcpy(p->partno, strtok(st, ":"));
       strcpy(p->desc, strtok(NULL, ":"));
       p->quantity = atoi(strtok(NULL, ":"));
       p->supplier = atoi(strtok(NULL, ":"));
       if (p->supplier < MaxSuppNum)
         {      
          okm = insert(p, m);
          if (okm)
            oks = insert(p, s[p->supplier]); 
         }                 
      }
    }
 fclose(fptr);
}

int change; /* change globally declared to update quantity due to limitations
                 in applycurrent */

void ChangeQuantity(partptr p)
/* ChangeQuantity updates the quantity of part (p) by change. */
{
 p->quantity += change;
}

void ShowPart(partptr p)
/* ShowPart displays the part's attributes. */
{
 printf("%-9s %-25s %-7d %d\n", p->partno, p->desc, p->quantity, p->supplier);
}
 
void NewPart(glist mast, glist *supp, char *s, int MaxSuppNum)
/* NewPart brings in a string (s) and parses it into struct part's components.
     If the supplier is within range, it attempts to insert it into the
     master (mast) and supplier (supp) lists and returns the proper message. */
{
 int okm, oks; /* return values from insert */
 partptr p = (partptr)malloc(sizeof(parttype));
 okm = oks = 0;
 p = (partptr)malloc(sizeof(parttype));   
 strcpy(p->partno, strtok(s, ":"));
 strcpy(p->desc, strtok(NULL, ":"));
 p->quantity = atoi(strtok(NULL, ":"));
 p->supplier = atoi(strtok(NULL, ":"));
 if (p->supplier < MaxSuppNum)
   {
     okm = insert(p, mast);
     if (okm) 
       {
        oks = insert(p, supp[p->supplier]);
        printf("%s inserted.\n", p->partno);
       }
     else
       printf("%s not inserted -- duplicate.\n", p->partno);
   }
 else
   printf("Unable to insert %s -- supplier out of bounds.\n", p->partno);
}

void ShowPartWithoutSupplier(partptr p)
/* ShowPartWithoutSupplier displays the part's attributes minus the supplier */
{
 printf("     %-9s %-25s %d\n", p->partno, p->desc, p->quantity);
}

void ShowAll(glist m, glist *s, int MaxSuppNum)
/* ShowAll displays all of the nonempty supplier lists. */
{
 int i;
 if (empty(m))
   printf("List is empty.  Cannot display supplier list.\n");
 else
   for (i=0; i < MaxSuppNum; i++)
     {
      if (empty(s[i]) == 0)
        { 
         printf("Supplier %d:\n",i);
         applyall(ShowPartWithoutSupplier, s[i]);
        }
     }
}

int supnum; /* globally declared to access supplier number for deletion from
                   the supplier list */

void getsupplier(partptr p)
{
 supnum = p->supplier;
}

void KillItem(glist m, glist *sup, char *s)
/* KillItem seeks the string s in the master list (m).  If it is found then
    the data is deleted from the lists. The proper message is then displayed.*/
{
 int found; /* return value from seek */
 found = seek(s, m);
 if (found)
   {
    applycurrent(getsupplier, m);
    applycurrent(free, m);
    delete(m);
    seek(s, sup[supnum]);
    delete(sup[supnum]);
    printf("Part %s removed.\n", s);
   }
 else printf("Part %s not found. Remove failed.\n", s);
}

FILE *fptr; /* file declared non-local to write functions so applyall can
                  be used with fprintf */

void WritePartToFile(partptr p)
/* WritePartToFile writes the part to the file */
{
 fprintf(fptr, "%s:%s:%d:%d\n", p->partno, p->desc, p->quantity, p->supplier);
}

void SaveInv(glist m, char *f)
/* SaveInv opens the file (f) for writing and returns the new list (m) to the 
     file in its original form. */
{
 if ((fptr = fopen(f, "w")) == NULL)
   {
    printf("Unable to open file %s for output.\n", f);
    exit(1);
   }
 else
   {
    printf("Saving inventory to file.........\n"); 
    applyall(WritePartToFile, m);
   }
 fclose(fptr);
}

void KillInv(glist m, glist *s, int MaxSupNum)
/* KillInv frees the parts and destroys all of the lists. */
{
 int i; /* loop index */
 printf("Destroying Inventory List.\n");
 applyall(free, m);
 destroylist(m);
 for (i=0; i < MaxSupNum; i++)
   destroylist(s[i]);
}

main(int argc, char *argv[])
{
    const int _maxLineLength = 50;

 glist master; /* master list */
 glist *suppliers; /* array of supplier lists */
 int found, supplier, i, MaxSuppNum = atoi(argv[1]);
   /* found is a return value from seek. supplier is a supplier number.
        MaxSuppNum is maximum number of suppliers given from command-line
        entry.  i is a loop index. */ 
 char st[_maxLineLength], partid[9];
   /* st is a string read from stdin.  partid is a partnumber */
 suppliers = (glist *)malloc(MaxSuppNum * sizeof(glist));
 master = createlist();
 for (i=0; i<MaxSuppNum; i++)
   suppliers[i] = createlist();
 getinv(master, suppliers, argv[2], MaxSuppNum);
 while ((fgets(st, _maxLineLength, stdin) != NULL) && (st[0] != 'X') && (st[0] != 'x') && (st[0]!= 'Q') && (st[0] != 'q'))
   {
    found = 0;
    switch (st[0])
      {
       case 'a':
       case 'A': sscanf(st+1, "%s %d", partid, &change);
                 found = seek (partid, master);
                 if (found)
		   {
                    applycurrent(ChangeQuantity, master);
                    printf("Quantity of part %s updated.\n",partid);
		   }
                 else
                   printf("Part %s not found for quantity update\n",partid);
                 break;
       case 'd':
       case 'D': found = seek(st + 1, master);
                 if (found)
                   applycurrent(ShowPart, master);
                 else
                   printf("Part %s not found.  Cannot display.\n",st+1);
                 break;
       case 'i':
       case 'I': NewPart(master, suppliers, st + 1, MaxSuppNum); break;
       case 'p':
       case 'P': ShowAll(master, suppliers, MaxSuppNum); break;
       case 'r':
       case 'R': KillItem(master, suppliers, st + 1); break;
       case 'm':
       case 'M': if (empty(master))
                   printf("List is empty. Cannot display\n");
                 else
                   applyall(ShowPart, master);
                 break;
       case 's':
       case 'S': supplier = atoi(st+1);
                 if ((empty(suppliers[supplier])) || (supplier >= MaxSuppNum))
		   printf("Supplier number %d is empty.\n", supplier);
                 else 
		   {
                    printf("Supplier %d:\n", supplier);
                    applyall(ShowPartWithoutSupplier, suppliers[supplier]); 
		   }
                 break;
      }
    printf("\n");
   }   
 if ((st[0] == 'Q') || (st[0] == 'q'))
    SaveInv(master, argv[2]);
 KillInv(master, suppliers, MaxSuppNum); 
}
 

