/* Erick Nave
   Operating Systems
   Phase 1 - Memory Manager (memory.c)
 
   The Memory Manager implements a free-space management system to
     allocate and free memory blocks for the operating system.  This
     is achieved through the functions initmem_(), getmem_(), and
     freemem_() */
 
#include <stdio.h>
#include "memory.h"
 
freeptr FSLPTR;
int MEMSIZE;    /* total size of memory available */
 
int round16(int num)
/* round16 takes a number and rounds it up to a multiple of 16 */
{
 if ((num % 16) != 0)
  return ((num / 16) + 1) * 16;
 else
  return num;
}
 
 
void initmem_()
/* initmem_ initializes the memory into 2 blocks: a 16 byte block for
    the dummy header and the rest of the memory in another block.  It
    sets the global FSLPTR to the dummy node */
{
 int start, end;
 
 start = round16(STARTMEM);
 end = round16(ENDMEM);
 MEMSIZE = end - start - 16;
                       /* set up dummy node */
 FSLPTR = (freeptr)start;
 FSLPTR->size = 0;
 FSLPTR->next = (freeptr)(start + 16);
 
                /* set up rest of memory as one block */
 FSLPTR->next->size = MEMSIZE;
 FSLPTR->next->next = NULL;
}
 
 
void *getmem_(int size)
/* getmem_ allocates all of the necessary storage blocks in the system.
     getmem_ needs the size of the requested block as an input
     parameter.  It searches the list of memory blocks for the first
     available block conforming to the size requirements.  It returns:
 
         0 if memory requirements are impossible to meet,
         1 if there is no block meeting the size requirements, or
         the address of the block.
 
     If the memory needed is of the exact size of the block, the block
     is deleted.  If the block is larger, the block is then split so
     that memory isn't wasted. */
{
 freeptr temp, prev; /* pointers for list traversal */
 void *retval = 0;   /* return value */
 
 if (size <= 0) size = 16;
 else size = round16(size); /* round up size to multiple of 16 */
 
 if (size <= MEMSIZE)
  {
          /* it is possible to fit the program so search blocks */
   temp = FSLPTR->next;
   prev = FSLPTR;
   while ((temp->size < size) && (temp != NULL))
    {
     prev = temp;
     temp = temp->next;
    } /* end while */
 
          /* Search is complete.  Check to see if block is found */
   if (temp == NULL) retval = (freeptr)1;  /* not found */
   else if (temp->size == size)   /* exact fit */
    {
     retval = temp;
     prev->next = temp->next;
    } /* end if exact fit */
   else                           /* break up block */
    {
     retval = temp;
     prev->next = (freeptr)((int)temp + size);
     prev->next->size = temp->size - size;
     prev->next->next = temp->next;
    } /* end breakup */
  } /* end if size < end - start */
 
 return retval;
}
 
 
void freemem_(void *addr, int size)
/* freemem_ frees a storage block.  It expects the address and size of
    the block to be freed as input parameters.  It then finds the proper
    position for the block in the list and either inserts it into the
    list or merges it with adjacent blocks */
{
 freeptr prev, temp, node; /* list nodes */
 
 if (size <= 0) size = 16;
 else size = round16(size);
 
 node = (freeptr)addr;
 
                         /* find slot */
 prev = FSLPTR;
 temp = FSLPTR->next;
 while ((node > temp) && (temp != NULL))
  {
   prev = temp;
   temp = temp->next;
  }
 
               /* slot found - check for adjacency */
 if ((int)prev + prev->size == (int)addr)           /* left side */
  {
   prev->size += size;
   if ((temp != NULL) && ((int)prev + prev->size == (int)temp))
    {                                                 /* both sides */
     prev->size += temp->size;
     prev->next = temp->next;
    }
  }
 else if ((temp != NULL) && ((int)addr + size == (int)temp))
  {                                                   /* right side */
   prev->next = node;
   node->size = size + temp->size;
   node->next = temp->next;
  }
 else  /* not adjacent so simply insert into list */
  {
   node->size = size;
   node->next = temp;
   prev->next = node;
  }
}
