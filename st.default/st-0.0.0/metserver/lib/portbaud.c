#include <memory.h>
#include <stdio.h>
#include <termio.h>

int portbaud(port, baud)   /* only to reset MAT BAUD */
int *port;
long *baud;
{
  struct termio term;

  if (ioctl(*port, TCSBRK, 0)==-1)   /* send a break to reset mats */
    return -1;

  if (ioctl(*port, TCGETA, &term) == -1)
    return -2;

  if (*baud>9600)
    return -3;

  term.c_cflag &= ~CBAUD;
  term.c_cflag &= ~CSTOPB;
  switch ((int) *baud){
    case 110:
      term.c_cflag |= B110;
      term.c_cflag |= CSTOPB;
      break;
    case 300:
      term.c_cflag |= B300;
      break;
    case 600:
      term.c_cflag |= B600;
      break;
    case 1200:
      term.c_cflag |= B1200;
      break;
    case 2400:
      term.c_cflag |= B2400;
      break;
    case 4800:
      term.c_cflag |= B4800;
      break;
    case 9600:
      term.c_cflag |= B9600;
      term.c_cflag |= CSTOPB;
      break; 
    default:
      return -3;
      break;
  }
  if(ioctl (*port, TCSETA, &term)==-1)
    return -4;

  return 0;
}
