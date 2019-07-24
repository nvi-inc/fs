/* limit

   Limit angles to the useful range.
   Copied from FORTRAN.
*/

#include <math.h>
#include "../include/dpi.h"

void limit(a1,a2)
double *a1,*a2;
/* a1 is ra  or az, limited to 0 to 2pi
   a2 is dec or el, limited to -pi to +pi
*/

{
  *a1=fmod(*a1+DTWOPI,DTWOPI);
  if (fabs(*a2) > DPI/2.0) {
    *a2 = (*a2 > 0) ? DPI-*a2 : -DPI-*a2;
    *a1 = fmod(*a1+DPI,DTWOPI);
  }
}
