/* Erick Nave
   Discrete Structures
   Program 1 - Maximum Cycle Length (nave.cpp)
   Due Oct. 1  */

/* Program 1 takes a matrix from input and determines:

           1) if it is connected.
           2) if connected, its maximum cycle length (MCL)

   The MCL of the matrix is the greatest length of a minimum cycle of a
       vertex to itself.  Its connectivity is determined by keeping a
       running sum of the matrix being multiplied by itself.  */

#include <stdio.h>
#include <math.h>

#define MaxMatrixSize 50

void MatrixMult(short A[MaxMatrixSize][MaxMatrixSize],
                short B[MaxMatrixSize][MaxMatrixSize],
                short C[MaxMatrixSize][MaxMatrixSize],
                int size)
  /* MatrixMult performs a matrix multiplication of A and B using ands
       and ors and places the result in C.  Size is the size of the
       matrices. */
{
 int i,k,x;  /* loop indices */
 short sum;    /* result of ors of row X col ands */

 for (i=0; i < size; i++)
  for (k=0; k < size; k++)
   {
    for (x=0, sum=0; x<size && sum == 0; x++)
     sum = sum | (A[i][x] && B[x][k]);
    C[i][k] = sum;
   }
}

int MatrixAdd (short int A[MaxMatrixSize][MaxMatrixSize],
               short int B[MaxMatrixSize][MaxMatrixSize],
               int size)
  /* MatrixAdd performs a matrix addition of A and B using ors and places
        the result in B.  Size is the size of the matrices.  MatrixAdd
        also checks to see if B is a connected matrix by checking to see
        if each or produces a 0, making it not connected.  If connected,
        a 1 is returned, otherwise a 0 is returned. */
{
 int i,k;      /* loop indices */
 int conn = 1; /* Assume connected till proven not so */

 for (i=0; i < size; i++)
  for (k=0; k < size; k++)
   {
    B[i][k] = A[i][k] | B[i][k];
    if (B[i][k] == 0) conn = 0;
   }

 return conn;
}

int IsReflexive (short A[MaxMatrixSize][MaxMatrixSize],
                 int size)
  /* IsReflexive tests to see if A is reflexive.  If it is then a 1 is
        returned so that the MCL can be determined, otherwise a 0
        is returned.  Size is the size of the matrix.  */
{
 int i;       /* loop index */
 int ref = 1; /* Assume reflexive till proven otherwise */

 for (i=0; i < size; i++)
  if (A[i][i] == 0) ref = 0;

 return ref;
}

              /* main body of the program */
void main()
{
 static short Orig[MaxMatrixSize][MaxMatrixSize];
   /* Original Matirx from input */
 static short Prod1[MaxMatrixSize][MaxMatrixSize];
 static short Prod2[MaxMatrixSize][MaxMatrixSize];
   /* Prod1 and Prod2 used to multiply Orig to itself multiple times */
 static short Sum[MaxMatrixSize][MaxMatrixSize];
   /* Sum is the running sum of the products */
 int size;
   /* size of the matrices */
 int power;
   /* power that the matrix is raised to in product */
 int MCL;
   /* maxmimum cycle length of the matrix */
 int connected = 0;
   /* is connected = 1.  not connected = 0 */
 int reflexive = 0;
   /* if Sum is reflexive then MCL has been found */
 FILE *MatrixFile;
   /* pointer to the matrix file */
 int i,k;
   /* loop indices */

                        /* open file and get input */
 if ((MatrixFile = fopen("a:file.inp", "r")) == NULL)
   printf("Cannot open file.inp. \n");
 else
  {
   fscanf(MatrixFile,"%d",&size); /* get 1st size from file */
   while (size)
    {
     power = 1;
     MCL = 0;
                            /* read in matrix */
     for (i=0; i<size; i++)
      for (k=0; k<size; k++)
       {
        fscanf(MatrixFile,"%d",&Orig[i][k]);
        Prod1[i][k] = Orig[i][k];
        Prod2[i][k] = Orig[i][k];
        Sum[i][k] = Orig[i][k];
       }
                     /* main processing of matrix */
     connected = MatrixAdd(Orig, Orig, size);
     if ((reflexive = IsReflexive(Orig, size)) == 1)
       MCL = 1;
     while (!connected && power < size)
      {
       power++;
       if ((power % 2) == 0)
        {
         MatrixMult(Orig, Prod1, Prod2, size);
         connected = MatrixAdd(Prod2, Sum, size);
        }
       else
        {
         MatrixMult(Orig, Prod2, Prod1, size);
         connected = MatrixAdd(Prod1, Sum, size);
        }
               /* if sum becomes reflexive, MCL found */
       if (!reflexive)
        if ((reflexive = IsReflexive(Sum, size)) == 1)
          MCL = power;
      }

                        /* display results */
     if (connected) printf("MCL = %d\n", MCL);
     else printf("Not connected.\n");   
     fscanf(MatrixFile,"%d",&size);
    }
  }
}