#include <termio.h>
#include <stdio.h>

int portflush_(port)
int *port;

{
  if(ioctl(*port,TCFLSH, 0)==-1)  /* flush the input queue */
    return -1;

  return 0;
}
