/* Pablo de Vicente */

#include <stdio.h>
#include <unistd.h>

int portclose(port)
int *port;

{
  if(close(*port)!=0)
    return -1;

  return 0;

}
