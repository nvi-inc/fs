/* Pablo de Vicente */

#include <stdio.h>
#include <unistd.h>

int portclose_(port)
int *port;

{
  if(close(*port)!=0)
    return -1;

  return 0;

}
