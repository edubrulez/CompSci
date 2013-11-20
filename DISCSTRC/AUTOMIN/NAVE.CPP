/* Erick Nave
   Discrete Structures
   Extra Credit Program - Finite State Machine Minimizer
   Due: Mon, Nov. 6

   This program expects input from file.inp.  The input is the number of
     states in the machine.  Then the next state and output functions are
     read in.  A relation matrix is then produced to reflect the partition
     of the machine.  It then breaks down the partition until it can be
     broken down no further.  The minimized functions will then be output
     to the screen */

#include <stdio.h>

#define maxstates 9

static int ns[2][maxstates];     /* next state function */
static int o[2][maxstates];      /* output function */

static int rel1[maxstates][maxstates];      /* relation matrices */
static int rel2[maxstates][maxstates];

int CheckandCopy()
  /* Check and copy checks to see if the relation matrices are equal.
       If they are, a 1 is returned.  Else relation 2 becomes relation 1
       and a 0 is returned. */
{
 int i,j;   /* loop indices */
 int same = 1;  /* matrices are same */

 for(i=0; i<maxstates; i++)
  for(j=0; j<maxstates; j++)
   if (rel1[i][j] != rel2[i][j])
    {
     rel1[i][j] = rel2[i][j];
     same = 0;
    }
 return same;
}

void main()
{
 int totstates;  /* total number of states (read from input file) */
 int i,j,k;      /* loop indices */
 FILE *infile;   /* pointer to input file */
 int good;       /* good if next states are related */
 int s1,s2;      /* 2 states for comparison */

 if ((infile = fopen("a:file.inp", "r")) == NULL)
  printf("Cannot open file.inp.\n");
 else
  {
                      /* get number of states */
   fscanf(infile,"%d",&totstates);

                    /* get next state function */
   for(i=0; i<totstates; i++)
    fscanf(infile,"%d",&ns[0][i]);
   for(i=0; i<totstates; i++)
    fscanf(infile,"%d",&ns[1][i]);

                    /* get output function */
   for(i=0; i<totstates; i++)
    fscanf(infile,"%d",&o[0][i]);
   for(i=0; i<totstates; i++)
    fscanf(infile,"%d",&o[1][i]);

                    /* define relation matrices */
   for(i=0; i<totstates; i++)
    for(j=0; j<totstates; j++)
     if ((o[0][i] == o[0][j]) && (o[1][i] == o[1][j]))
      rel1[i][j] = rel2[i][j] = 1;

                   /* perform partition breakup */
   do {
    for(i=0; i<totstates; i++)
     for(j=0; j<totstates; j++)
      if(rel1[i][j] == 1)      /* related in R(n-1) */
       {
        good = 1;
        s1 = ns[0][i];
        s2 = ns[0][j];
        if(rel1[s1][s2] == 0) good = 0;
        s1 = ns[1][i];
        s2 = ns[1][j];
        if(rel1[s1][s2] == 0) good = 0;
        if(good == 0) rel2[i][j] = 0;
       }
   } while(CheckandCopy() == 0);

                  /* fix next state and output functions */
   for(i=0; i<totstates; i++)
    for(j=i+1; j<totstates; j++)
     if(rel1[i][j])
      {
                  /* remove reference of state j */
       for(k=0; k<totstates; k++)
        {
         if(ns[0][k] == j) ns[0][k] = i;
         if(ns[1][k] == j) ns[1][k] = i;
        }
                  /* flag state j to ignore */
       ns[0][j] = ns[1][j] = o[0][j] = o[1][j] = 99;
      }

                   /* output new next state function */
   printf("v |");
   for(i=0; i<totstates; i++)
    if(ns[0][i] != 99)
     printf(" s%d",i);
   printf("\n-----------------------------------------\n0 |");
   for(i=0; i<totstates; i++)
    if(ns[0][i] != 99)
     printf(" s%d",ns[0][i]);
   printf("\n1 |");
   for(i=0; i<totstates; i++)
    if(ns[1][i] != 99)
     printf(" s%d",ns[1][i]);
   printf("\n\n");

                    /* output new output function */
   printf("w |");
   for(i=0; i<totstates; i++)
    if(o[0][i] != 99)
     printf(" s%d",i);
   printf("\n-----------------------------------------\n0 |");
   for(i=0; i<totstates; i++)
    if(o[0][i] != 99)
     printf(" %d ",o[0][i]);
   printf("\n1 |");
   for(i=0; i<totstates; i++)
    if(o[1][i] != 99)
     printf(" %d ",o[1][i]);
   printf("\n\n");
  } /* end else */
}/* end minimizer */
