#include <memory.h>
#include <stdio.h>
#include <fcntl.h>
#include <termio.h>
#include <linux/serial.h>
#include <sys/errno.h>
#include <limits.h>

#ifdef DIGI
#include "/usr/src/linux/drivers/char/digi.h"  /* yechh, abs. path... */
#endif

int portopen_(port, name, len, baud, parity, bits, stop)
int *port;
char *name;   /* hollerith */
int *len;
long *baud;
int *parity;
int *bits;
int *stop;
{
  struct termio term;
  char device[65];
  char *end;

  if (*len < 0 || *len > 64)
    return -1;

  end = memccpy(device, name, ' ', *len);
  if (end != NULL)
    *(end-1) = '\0';
  else
    *(device + *len) = '\0';

  if ((*port = open(device, O_RDWR) )<0)
    return -2;

  if (ioctl(*port, TCGETA, &term) == -1) {
    return -3;
  }

/* ?
  term.c_iflag &= ~(INLCR | ICRNL | IUCLC | IXON | BRKINT);
  term.c_iflag |= ISTRIP;
*/

  term.c_iflag |= IGNBRK;
  term.c_iflag &= ~(BRKINT | IGNPAR | PARMRK | INPCK | ISTRIP | INLCR |
                    IGNCR | ICRNL | IUCLC | IXON | IXANY | IXOFF);

  term.c_oflag &= ~OPOST;

  term.c_lflag &= ~(ICANON | ISIG | ECHO);

  term.c_cc[VMIN] = 1;
  term.c_cc[VTIME] = 1;

  switch (*stop) {
     case 1:
       term.c_cflag &= ~CSTOPB;
       break;
     case 2:
       term.c_cflag |= CSTOPB;
       break;
     default:
        return -4;
        break;
   }

  term.c_cflag &= ~CSIZE;
  switch (*bits) {
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
       return -5;
       break;
  };

  switch (*parity) {
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
        return -6;
        break;
  }

  term.c_cflag &= ~CBAUD;
#ifdef USE_OLD_SPECIAL_FLAGS
  if( *baud==38400 )
    term.c_cflag |= B38400;
  else if( *baud==57600)
    term.c_cflag |= B38400;
  else if( *baud==115200)
    term.c_cflag |= B38400;
  else
#endif
  if ((*baud) > INT_MAX)  /* to check overflow in the following (int) */
    return -7;
  else
  switch ((int)*baud){
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
#ifndef USE_OLD_SPECIAL_FLAGS
    case 38400:
      term.c_cflag |= B38400;
      break;
    case 57600:
      term.c_cflag |= B57600;
      break;
    case 115200:
      term.c_cflag |= B115200;
      break;
#endif
    default:
      return -7;
  };
  if (ioctl (*port, TCSETA, &term)==-1)
    return -8;

#ifdef USE_OLD_SPECIAL_FLAGS
  /* We attempt to adjust 38400 baud into higher speeds. */
  /* Linux can give 57600 or 115200 when std Unix 'termios' call */
  /* requests for 38400. */
  /* Now we need to adjust the special bits whenever "slower" */
  /* baud rates are requested, too: namely DigiBoard wants */
  /* to reuse 50/75/110 baud and to get _these_ slow rates, */
  /* we must cancel the fastbaud bit... */
  if (*baud > 0)
  {
    struct serial_struct allSerialSettings;
    int oldBits;

    if (ioctl(*port, TIOCGSERIAL, &allSerialSettings) == 0) {
      /* We can do the change in Linux 'serial.c' way. */
      oldBits = allSerialSettings.flags & ASYNC_SPD_MASK;

      /* Zero the SPD bits first.  (== "normal" 38400 baud) */
      allSerialSettings.flags &= ~ASYNC_SPD_MASK;

      if (*baud > 86400) {
        /* 115200 baud. */
        allSerialSettings.flags |= ASYNC_SPD_VHI;
      } else if (*baud > 48000) {
        /* 57600 baud. */
        allSerialSettings.flags |= ASYNC_SPD_HI;
      } else {
        /* Leave at genuine 38400 baud (or lower.) */
      }

      /* Change (all the) serial settings only if they really need changing.
*/
      if ((allSerialSettings.flags & ASYNC_SPD_MASK) != oldBits) {
        if(ioctl(*port, TIOCSSERIAL, &allSerialSettings) == -1) {
          return -10;
        }
      }
    } else {  /* couldn't use 'serial.c'-style SPD_[V]HI */
      if (errno == EINVAL) {
#ifdef DIGI
        /* 'TIOCGSERIAL' didn't work, perhaps a Digiboard special will? */
        digi_t digiSettings;
        digi_t oldDigiSettings;
        struct termio oldSettings;

        /* We start by re-getting the current termio + Digi settings: */
        if (ioctl(*port, TCGETA, &term) != 0) {
          return -3;
        }
        oldSettings = term;
        if (ioctl(*port, DIGI_GETA, &digiSettings) != 0) {
          return -3;  /* xxx: perhaps a new code? */
        }
        oldDigiSettings = digiSettings;

        if (*baud > 86400) {
          /* 115200 baud. */
          digiSettings.digi_flags |= DIGI_FAST;
#define SET_SPEED(tp, speed) \
    (tp)->c_cflag &= ~CBAUD; \
    (tp)->c_cflag |= speed
          SET_SPEED(&term, B110);
        } else if (*baud > 67200) {
          /* 76800 baud. */
          digiSettings.digi_flags |= DIGI_FAST;
          SET_SPEED(&term, B75);
        } else if (*baud > 48000) {
          /* 57600 baud. */
          digiSettings.digi_flags |= DIGI_FAST;
          SET_SPEED(&term, B50);
#undef SET_SPEED
        } else {
          /* Leave at genuine 38400 baud (or lower.) */
          digiSettings.digi_flags &= ~DIGI_FAST;
          /* (The baud rate has been already set in standard settings
              above.) */
        }

        /* Change Digi settings + termio settings (termio again), */
        /* if either Digi or std. baud rate changed. */
        if (digiSettings.digi_flags != oldDigiSettings.digi_flags) {
          if (ioctl(*port, DIGI_SETAW, &digiSettings) != 0) {
            return -8;  /* xxx: perhaps a new code? */
          }
        }
        if (term.c_cflag != oldSettings.c_cflag) {
          if (ioctl (*port, TCSETA, &term) != 0) {
            return -8;
          }
        }
#else
        return -9;
#endif
      } else {
        /* Getting Linux-specific serial settings failed */
        /* in other way than EINVAL... */
        return -9;
      }
    }  /* else couldn't use 'serial.c'-style high speeds */
  }  /* if > 0 baud ie. baud rate change required */
#endif

  return 0;
}
