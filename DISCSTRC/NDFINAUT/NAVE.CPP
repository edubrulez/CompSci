/* Erick Nave
   Discrete Structures
   Program 2 - Nondeterministic Finite Automata Simulator
   Due: Wed, Nov. 1

   Program 2 reads from an input file the following:

     1) the # of states
     2) the graph for input of 0
     3) the graph for input of 1
     4) the final states

   After the matrix representations are generated, strings of "bits" are
      read from the input file and are run through the automata.
      Acceptance or rejection is then output to the screen */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define maxstates 9

static int zero[maxstates][maxstates];
  /* matrix of connections based on input of 0 */

static int one[maxstates][maxstates];
  /* matrix of connections based on input of 1 */

static int final[maxstates];
  /* value is 1 if final state, 0 if not */

static int path[21];
  /* path string */

int sim(int st, int tsts, int n, char *bs)
  /* sim is the automata simulator.  It expects the current state (st),
      the total # of states (tsts), the position of the current bit (n), and
      the bit string itself (bs).  It places the current state into the path
      string.  It returns a one if the end of the bit string (null character)
      is encountered and is in a final state.  It returns a zero if the null
      character is encountered but is not in a final state.  Otherwise it
      selects the next state, and recursively calls itself. */
{
 int done;   /* acceptance found, done processing */
 int i;      /* loop index */

 path[n] = st;

 if (bs[n] == '\0')
  if (final[st])
   return 1;
  else
   {
    path[n] = '\0';
    return 0;
   }
 else
  {
   for(i=0, done=0; i < tsts && !done; i++)
    {
     if(bs[n] == '1')
      {
       if (one[st][i])
        done = sim(i, tsts, n+1, bs);
      }
     else
      if(zero[st][i])
       done = sim(i, tsts, n+1, bs);
    }
   if (!done) /* backtrack */
    {
     path[n] = '\0';
     return 0;
    }
   else return 1;
  }
}
 

void main ()
{
 int totstates;       /* total number of states (read from input file) */
 char bitstr[21];     /* bit string read from input file */
 FILE *infile;        /* pointer to the input file */
 int i,j;             /* loop indices */
 char finalline[80];  /* line of final states read from input file */
 char *num;            /* num gained from strtok of finalline */
 int result;          /* result of acceptance or rejection */

                     /* open file */
 if ((infile = fopen("a:file.inp", "r")) == NULL)
  printf("Cannot open file.inp.\n");
 else
  {
                   /* get number of states */
   fscanf(infile, "%d", &totstates);

                   /* get next state function for input of 0 */
   for(i = 0; i < totstates; i++)
    for(j = 0; j < totstates; j++)
     fscanf(infile, "%d", &zero[i][j]);

                   /* get next state function for input of 1 */
   for(i = 0; i < totstates; i++)
    for(j = 0; j < totstates; j++)
     fscanf(infile, "%d", &one[i][j]);

                   /* get final states */
   while (fgetc(infile)!='\n');
   fgets(finalline, 80, infile);
   num = strtok(finalline, " ");
   while (num != NULL)
    {
     final[atoi(num)] = 1;
     num = strtok(NULL, " ");
    }

                   /* process bit strings */
   while (fscanf(infile, "%s", &bitstr) != EOF)
    {
     result = sim(0, totstates, 0, bitstr);
     if (result)
      {
       printf("The string %s is accepted by the path:\n",bitstr);
       printf("     ");
       for (i=0; i <= strlen(bitstr); i++)
        if (i < strlen(bitstr))
         printf("%d-",path[i]);
        else printf("%d.\n",path[i]);
      }
     else printf("The string %s is rejected.\n",bitstr);
    }
  }
} /* end program 2 */