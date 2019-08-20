#include <memory.h>
#include <stdio.h>
#include <fcntl.h>
#include <termio.h>
#include <linux/serial.h>
#include <sys/errno.h>
#include <limits.h>

#ifdef DIGI
#include "/usr/src/linux/include/digi.h"  /* yechh, abs. path... */
#endif

/* error codes
 *
 *   old=FS 9.11.5 and earlier
 *   new=FS 9.11.6 and later
 *   errno indicates when errno contains additional (system) information
 *
 *   new   old errno   meaning
 *     0    0   no     no error
 *    -1   -1   no     name len bad: <0 or >64
 *    -2   -2   yes    open failed
 *    -3   -3   yes    TCGETA failed
 *    -4   -4   no     Stop bits bad, not 1 or 2
 *    -5   -5   no     bits per char bad: not 5, 6, 7, or 8
 *    -6   -6   no     Parity bad, not 0 (none), 1 (odd), or 2 (even)
 *    -7   -7   no     BAUD bad
 *    -8   -8   yes    TCSETA failed
 *    -9   -9   yes    TIOCGSERIAL failed with EINVAL and not DIGI
 *   -10  -10   yes    TIOCSSERIAL failed
 *   -11   -3   yes    Digi TCGETA failed
 *   -12   -3   yes    DIGI_GETA failed
 *   -13   -8   yes    DIGI_SETAW failed
 *   -14   -8   yes    DIGI TCSETA failed
 *   -15   -9   yes    TIOCGSERIAL failed with some other than EINVAL
 *   -16        yes    non-blocking open failed
 *   -17        yes    non-blocking TCGETA failed
 *   -18        yes    non-blocking TCSETA failed
 *   -19        yes    non-blocking close failed
 */

int portopen_(port, name, len, baud, parity, bits, stop)
int *port;
char *name;   /* hollerith */
int *len;
int *baud;
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

#ifdef FS_SERIAL_CLOCAL
  if ((*port = open(device, O_RDWR | O_NONBLOCK) )<0) {
    return -16;
  }

  if (ioctl(*port, TCGETA, &term) == -1) {
    return -17;
  }

  term.c_cflag |= CLOCAL;

  if (ioctl (*port, TCSETA, &term)==-1) {
    return -18;
  }

  if(close(*port)<0) {
    return -19;
  }
#endif

  if ((*port = open(device, O_RDWR) )<0) {
    return -2;
  }

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
          return -11;
        }
        oldSettings = term;
        if (ioctl(*port, DIGI_GETA, &digiSettings) != 0) {
          return -12;
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
            return -13;
          }
        }
        if (term.c_cflag != oldSettings.c_cflag) {
          if (ioctl (*port, TCSETA, &term) != 0) {
            return -14
          }
        }
#else
        return -9;
#endif
      } else {
        /* Getting Linux-specific serial settings failed */
        /* in other way than EINVAL... */
        return -15;
      }
    }  /* else couldn't use 'serial.c'-style high speeds */
  }  /* if > 0 baud ie. baud rate change required */
#endif

  return 0;
}
