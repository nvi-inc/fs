
#include <termio.h>

#ifdef _NEEDED
int fc_gwinsz_()
#else
int fc_gwinsz()
#endif
{
     struct winsize ws;
     int *winlen;

     ioctl(0,TIOCGWINSZ,&ws);
     return((int) ws.ws_row);
}
