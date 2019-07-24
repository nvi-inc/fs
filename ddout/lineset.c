#include <memory.h>
#include <stdio.h>
#include <fcntl.h>
#include <termio.h>

int lineset(port, baud, parity, bits, stop)
int port;
long baud;
int parity;
int bits;
int stop;
{
  struct termio term;

  if (ioctl(port, TCGETA, &term) == -1) {
    return -1;
  }

  term.c_oflag |= (OPOST|ONLCR);

  switch (stop) {
     case 1:
       term.c_cflag &= ~CSTOPB;
       break;
     case 2:
       term.c_cflag |= CSTOPB;
       break;
     default:
        return 1;
        break;
   }

  term.c_cflag &= ~CSIZE;
  switch (bits) {
     case 5:
       term.c_cflag |= CS5;
       break;
     case 6:
       term.c_cflag |= CS6;
       break;
     case 7:
       term.c_cflag |= CS7;
       break;
     case 8:
       term.c_cflag |= CS8;
       break;
     default:
       return 2;
       break;
  };

  switch (parity) {
      case 0:
        term.c_cflag &= ~PARENB;
        break;
      case 1:
        term.c_cflag |= PARENB;
        term.c_cflag |= PARODD;
        break;
      case 2:
        term.c_cflag |= PARENB;
        term.c_cflag &= ~PARODD;
        break;
      default:
        return 3;
        break;
  }

  term.c_cflag &= ~CBAUD;
  if( baud==38400 )
    term.c_cflag |= B38400;
  else if (baud > 32767)
    return 4;
  switch ((int)baud){
    case 50:
      term.c_cflag |= B50;
      break;
    case 75:
      term.c_cflag |= B75;
      break;
    case 110:
      term.c_cflag |= B110;
      break;
    case 134:
      term.c_cflag |= B134;
      break;
    case 150:
      term.c_cflag |= B150;
      break;
    case 200:
      term.c_cflag |= B200;
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
    case 1800:
      term.c_cflag |= B1800;
      break;
    case 2400:
      term.c_cflag |= B2400;
      break;
    case 4800:
      term.c_cflag |= B4800;
      break;
    case 9600:
      term.c_cflag |= B9600;
      break;
    case 19200:
      term.c_cflag |= B19200;
      break;
    default:
      return 4;
  };
  if(ioctl (port, TCSETA, &term)==-1)
    return -1;

  return 0;
}
