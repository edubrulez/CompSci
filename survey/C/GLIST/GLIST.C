/* Erick Nave
   Survey of Programming Languages 
   Program 3 - glist.c
   Start: 3-10-94
   Last Update: 3-28-94

   glist.c is the ordered list adt implemented with dynamic memory with a 
       dummy node. 
*/

#include <stdio.h>
#include <string.h>
#include "glist.h"

typedef struct lnode *lnodeptr;

glist createlist()
/* createlist returns a pointer to glist with head pointing to a dummy node
     with current and all pointers in the dummy node = null */
{
 glist l;
 l = (glist)malloc(sizeof(struct list));
 l->head = (lnodeptr)malloc(sizeof(struct lnode));
 l->head->prior = l->head->data = l->head->next = l->current = NULL;
 return l;
}

void destroylist(glist l)
/* destroy list frees all dynamic memory associated with lnodes */
{
 lnodeptr p;
 for (p = l->head; p != NULL; p = p->next)
  free(p);
 free(l);
}

void applyall(voidfunctionptr f, glist l)
/* applyall applies a given function (f) to every data item in a list (l) */
{
 lnodeptr p;
 for (p = l->head->next; p != NULL; p = p->next)
   f(p->data);
}

void applycurrent(voidfunctionptr f, glist l)
/* applycurrent applies a given function (f) to the current data item
      in a list (l) */
{
 if (l->current != NULL)
   f(l->current->data);
}

int seek(char *c, glist l)
/* seek searches a list (l) for a data item whose key matches a string (c).
     If it is found, current is assigned that address and retruns a 1.
     Otherwise a 0 is returned. */
{
 lnodeptr p = l->head->next;
 int found = 0;
 while ((p != NULL) && (found == 0))
   {
    if (strcmp(c, p->data) == 0)
      {
       found = 1;
       l->current = p;
      }
    else
      p = p->next;
   }
 return found;
}

int insert(void *d, glist l)
/* insert inserts a data item (d) in order by key (c) into a list (l).
     If a duplidate is found, a 0 is returned otherwise d is inserted and a 
      1 is returned. */
{
 int found = 0;
 lnodeptr temp, p, prev;
 found = seek(d, l);
 if (found == 1)
   return 0;
 else
   {
    p = l->head->next;
    prev = l->head;
    while ((p != NULL) && (strcmp((char *)d, (char *)p->data) > 0))
      {     
       prev = p;
       p = p->next;
      }
    temp = (lnodeptr)malloc(sizeof(struct lnode));
    if (p == NULL) /* end of list */
      {
       temp->prior = prev;
       temp->next = NULL;
       prev->next = temp;
      }
    else /* middle of list */
      {
       temp->prior = p->prior;
       temp->next = p;
       p->prior = temp;
       temp->prior->next = temp;
      }
    temp->data = d;
    return 1;
   }
} 

int delete(glist l)
/* delete deletes the current node from the list (l). If it is successful,
      it returns a 1.  Otherwise, it returns a 0. */
{
 if (l->current != NULL)
   {
    if (l->current->next != NULL)
      {
       l->current->prior->next = l->current->next;
       l->current->next->prior = l->current->prior;
      }
    else /* end of list */
      l->current->prior->next = NULL;
    free(l->current);
    l->current = NULL;
    return 1;

   }
 else return 0;
}

int empty(glist l)
/* empty returns a 1 if l->head->next = NULL, 0 otherwise. */
{
 return (l->head->next == NULL)?1:0;
}
