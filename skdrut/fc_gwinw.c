
#include <sys/termio.h>

#ifdef _NEEDED
int *fc_gwinw_()
#else
int *fc_gwinw()
#endif
{
     struct winsize ws;

     ioctl(0,TIOCGWINSZ,&ws);
     return((int) ws.ws_col);
}
