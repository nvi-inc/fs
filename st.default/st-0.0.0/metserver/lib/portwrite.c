#include <termio.h>

int portwrite(port, buff, len)
int *port;
char *buff;    /* hollerith */
int *len;
{
  if(write(*port, buff, *len)!=*len)
    return -2;

  return 0;
}
