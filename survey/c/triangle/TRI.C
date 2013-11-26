/* Erick Nave
   Survey of Programming Languages
   Program 1 - tri.c
   2-11-94

   tri.c reads three coordinates of the vertices of a triangle.  It then
     determines the distance between two vertices, the vertex angle between
     two sides, and the area of the triangle.        
*/

#include <stdio.h>
#include <math.h>

double slope (double x1, double y1, double x2, double y2)
/* slope determines the slope between two points */
{
  return (y1 - y2) / (x1 - x2);
}

double distance(double x1, double y1, double x2, double y2)
/* distance takes the coordinates of two points and computes the distance
     between them by using the distance formula */
{
  double newx, newy;
  newx = x1 - x2;
  newx = pow(newx, 2);
  newy = y1 - y2;
  newy = pow(newy, 2);
  return sqrt(newx + newy);
}

double angle(double adj1, double adj2, double opp)
/* angle computes the angle between 2 adjacent angles by using the law of
      cosines */
{
  double numerator, denominator, radian;
  numerator = pow(opp, 2) - pow(adj1, 2) - pow(adj2, 2);
  denominator = -1 * 2 * adj1 * adj2;
  radian = acos(numerator / denominator);
  return (180 * radian) / M_PI;
}

double area (double side1, double side2, double angle)
/* area computes the area of the triangle using two adjacent sides and the 
      angle between them. */
{
  double radian;
  radian = (angle * M_PI) / 180;
  return 0.5 * side1 * side2 * sin(radian);
}

main ()
{
  double x1, x2, x3, y1, y2, y3;
  double side1, side2, side3;
  double angle1, angle2, angle3;
  double trianglearea;  
  while (scanf("%lf%lf%lf%lf%lf%lf", &x1, &y1, &x2, &y2, &x3, &y3) != EOF)
    if (((x1==x2) && (x2==x3)) || ((y1==y2) && (y2==y3)))                    
      printf("(%lf,%lf), (%lf,%lf), and (%lf,%lf) form a line.\n\n\n",x1,y1,x2,         y2,x3,y3);
    else
      if (slope(x1,y1,x2,y2) == slope(x1,y1,x3,y3))
        printf("(%lf,%lf), (%lf,%lf), and (%lf,%lf) form a line.\n\n\n",x1,y1,            x2,y2,x3,y3);
    else
	{
      side1 = distance(x1,y1,x2,y2);
      side2 = distance(x2,y2,x3,y3);
      side3 = distance(x1,y1,x3,y3);
      printf("Side 1 between (%lf,%lf) and (%lf,%lf) is %lf.\n",x1,y1,x2,y2,             side1);
      printf("Side 2 between (%lf,%lf) and (%lf,%lf) is %lf.\n",x2,y2,x3,y3,             side2);
      printf("Side 3 between (%lf,%lf) and (%lf,%lf) is %lf.\n",x1,y1,x3,y3,             side3);
      angle1 = angle(side1, side2, side3);
      angle2 = angle(side2, side3, side1);
      angle3 = angle(side1, side3, side2);
      printf("The angle between sides 1 and 2 is %lf degrees.\n",angle1);
      printf("The angle between sides 2 and 3 is %lf degrees.\n",angle2);
      printf("The angle between sides 1 and 3 is %lf degrees.\n",angle3);
      trianglearea = area(side1, side2, angle1);
      printf("The area of this triangle is %lf.\n\n\n",trianglearea);
  }
}
