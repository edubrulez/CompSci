/* Erick Nave
   Survey of Programming Languages
   Start: 2-21-94
   Last Update: 2-28-94
   Program 2 - freq.c

   freq.c reads a stream of integers from standard input.  It uses two arrays
     to keep track of the numbers scanned and the frequency with which that
     number occurs.  A table in order by number, a table in order by
     frequency (using quicksort), and the table's mean and median are written
     to standard output.
*/

#include <stdio.h>

#ifndef TSIZE
#define TSIZE 200
#endif

int insert(int x, int num[], int freq[], int len)
/* insert uses a binary search to locate x in array num.  If it is not found 
      then x is inserted into the proper position in num and freq and the value
      of 1 is assigned to freq at that position. A 1 is then sent as a return 
      value.  If x is found then freq is incremented at that position and a 0 
      is returned. */
{
 int new, position, high, low, i;
   /* new is a "boolean" set according to if x is new or not.  position is the
        position in the array.  high and low are values used in the binary 
        search. i is a loop index */
 high = len - 1;
 new = 1;
 low = position = 0;
 /* Binary Search */
 while ((new == 1) && (low <= high))
   {
    position = (low + high) / 2;
    if (num[position] == x)
       new = 0;    
    else
      if (x < num[position])
        high = position - 1;
      else
        low = position + 1;        
   }
 /* Array Manipulation */
 if (new == 1 && len < TSIZE)
   {
    if (num[position] < x)
      position++;
    for (i = len; i > position; i--)
      {
       num[i] = num[i-1];
       freq[i] = freq[i-1];
      }
    num[position] = x;
    freq[position] = 1;
   }
 else
   freq[position]++;
 return new;
}

double mean(int num[], int freq[], int len)
/* mean determines the mean of the numbers in the table. */
{
 int i; /* loop index */
 double sum, accum;
   /* sum of all of the numbers.  accum counts the total number of numbers. */
 sum = accum = 0;
 for (i = 0; i < len; i++)
   {
    sum += (double)num[i] * (double)freq[i];
    accum += (double)freq[i];
   }
 return sum/accum;
}

double FindMed(int num[], int freq[], int len, int position)
/* FindMed returns the number in the spot determined by its position on the
      frequency table. */
{
 int i, accum;
    /* i is position in array. accum is the accumulator of frequencies */
 i = accum = 0;  
 while ((i < len) && (accum < position))
   {
    accum += freq[i];
    if (accum < position)
      i++;
   }
 return (double)num[i];
}

double median(int num[], int freq[], int len)
/* median determines the median of the numbers in the table.v */
{
 int i, accum;
    /* i is loop index.  accum is accumulator of total number of numbers */
 for (accum = i = 0; i < len; i++)
   accum += freq[i];
 if (accum % 2 == 0)
   return (FindMed(num, freq, len, accum/2) + FindMed(num, freq, len, (accum/2)                    + 1)) / 2;
 else
  return FindMed(num, freq, len, (accum / 2) + 1);
}

int partition (int num[], int freq[], int l, int h)
/* partition partitions the arrays into 2 parts according to freq.  It selects
      a pivot and moves all frequencies > pivot's to its left and all
      frequencies < pivots to its right.  It returns pivots position after
      the partitioning. */
{
 int freqpivot, numpivot;  /* values at the pivot position */
 freqpivot = freq[l];
 numpivot = num[l];
 while (l < h)
   {
    while ((freqpivot > freq[h]) && (l < h)) 
      h--;
    if (h != l)
      {
       num[l] = num[h];
       freq[l] = freq[h];
       l++;
      }
    while ((freq[l] > freqpivot) && (l < h))
      l++;
    if (h != l)
      {
       num[h] = num[l];
       freq[h] = freq[l];
       h--;
      }
   }
 num[h] = numpivot;
 freq[h] = freqpivot;
 return h;
}

void QuickSort(int num[], int freq[], int low, int high)
/* QuickSort calls partition to partition the arrays then recursively calls
     itself so that the segments will be put in order so the entire arrays
     will be in order */
{
 int pivot;
 pivot = partition (num, freq, low, high);
 if (low < pivot) 
   QuickSort (num, freq, low, pivot - 1);
 if (high > pivot)
   QuickSort (num, freq, pivot + 1, high);
}

void sort(int num[], int freq[], int len)
/* sort calls QuickSort. */
{ 
 QuickSort(num, freq, 0, len - 1);
} 

void PrintTable(int num[], int freq[], int len)
/* PrintTable prints the arrays to standard output. */
{
 int i; /* loop index */
 printf("Frequency Table\n");
 printf("    Number                        Occurrences\n");
 for (i=0; i < len; i++)
   printf(" %10d               %15d\n", num[i], freq[i]);
 printf("\n\n");
}
 
main ()
{
 static int num[TSIZE], freq[TSIZE]; /* the arrays of numbers & frequencies. */
 int length, x, result, error;
   /* length of arrays, x is number read, result is 1 or 0 returned by insert,
         error is "boolean" value checking to see if length is within the
         valid range. */
 double med; /* median */
 length = error = 0;
 if (scanf("%d", &x) != EOF) 
   {
    num[0] = x;
    freq[0] = 1;
    if (length < TSIZE)
      length++;
    else
      error = 1;
   }
 while ((scanf("%d", &x) != EOF) && (error != 1))
   {
    result = insert(x, num, freq, length);
    if (result == 1) 
      if (length < TSIZE) 
        length++;
      else 
        error = 1;
   }
 if (error != 1)
   {
    PrintTable(num, freq, length); 
    med = median(num, freq, length);
    sort(num, freq, length);
    PrintTable(num, freq, length); 
    printf("Mean = %.3f\n\n", mean(num, freq, length));
    printf("Median = %.3f\n", med);
   }
 else
   printf("\n\nToo many values for the table.\n\n");
}




