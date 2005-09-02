/* 04.06.23 AEM changes <sys/termio.h> -> <termio.h>
 04.06.23 AEM remove pointer from function (*fc_gwinsz -> fc_gwinsz)
 ?! why here was '*', not clear yet...
   ../sked/skcom.ftni : integer iwscn
   ../sked/prset.f : integer fc_gwinsz; iwscn = fc_gwinsz()
*/
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
     /* unsigned short int ws.ws_row */
     return((int) ws.ws_row);
}
