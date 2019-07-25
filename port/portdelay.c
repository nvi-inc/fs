#include <memory.h>
#include <stdio.h>
#include <fcntl.h>
#include <termio.h>

int portdelay(port,maxc,time)
int port,maxc,time;
{
  struct termio term;

  if (ioctl(port, TCGETA, &term) == -1) {
    return -3;
  }

  term.c_cc[VMIN] = maxc;
  term.c_cc[VTIME] = (time+9)/10;

  if(ioctl (port, TCSETA, &term)==-1)
    return -8;

  return 0;
}
