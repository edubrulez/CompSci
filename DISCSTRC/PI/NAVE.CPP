/* Erick Nave
   Discrete Structures
   Program 3 - Estimation of Pi

   Program 3 approximates the value of pi using the fact that in a large
     collection of random, positive integers, the probability that any
     pair of integers will have no positive common divisor other than 1 is:
                             6/(pi ** 2)
     Using this as a basis of the program, the user will input 3 integers:
       1) the seed for the random number generator
       2) the # of random numbers to be generated
       3) the upper boundary for the random numbers generated
     The random numbers will be generated and then the GCD will be
     determined for each ordered pair, keeping track of the number of pairs
     total and number with a GCD of 1.  Using these numbers and the formula
     above, PI will be approximated. */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define maxsize 100

static int nums[maxsize];  /* array of random numbers */


int GCD(int a, int b)
 /* GCD finds the greatest common divisor of a and b */
{
 int big, small; /* bigger and smaller of a and b */
 int mod;        /* mod of big and small */

 if (a > b)
  {
   big = a;
   small = b;
  }
 else
  {
   big = b;
   small = a;
  }

 if ((mod = (big % small)) != 0)
  while(mod)
   {
    big = small;
    small = mod;
    mod = big % small;
   }

 return small;
} /* end GCD */


void main()
{
 int i;                 /* seed */
 int n;                 /* number of random numbers */
 int k;                 /* upper bound */
 int x,y;               /* loop indices */
 int dup=0;               /* flag for duplicate found */
 double totpairs = 0;   /* total number of ordered pairs */
 double good = 0;       /* pairs with GCD of 1 */
 double approx;         /* approximation of pi */ 

 scanf("%d %d %d", &i, &n, &k);   /* get input values */

 if (n>k)
  {
   printf("n cannot be greater than k.\n");
   exit(1);
  }

                    /* generate random numbers */
 srand(i);
 x = 0;
 while(x < n)
  {
   dup = 0;
   nums[x] = random(k) + 1;
   for(y=0; y<x; y++)
    if(nums[y] == nums[x]) dup = 1;
   if(!dup) x++;
  }

                    /* determine # of GCDs = 1 */
 for(x = 0; x < n; x++)
  for(y = x+1; y < n; y++)
   {
    totpairs += 1;
    if (GCD(nums[x], nums[y]) == 1) good += 1;
   }

                    /* approximate PI */
 if(good == 0) approx = 0;
 else approx = sqrt(6.0 * totpairs / good);

 printf("%.0lf out of the %.0lf pairs had no positive", good, totpairs);
 printf(" common divisors except 1.\n");
 printf("   This gives us an estimated value of pi of %.7lf",approx);
} /* end program 3 */     