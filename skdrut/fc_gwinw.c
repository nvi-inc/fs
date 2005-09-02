// 04.06.23 AEM changes <sys/termio.h> -> <termio.h>
// 04.06.23 AEM remove pointer from function (*fc_gwinw -> fc_gwinw)
// ?! why here was '*', not clear yet...

// ../sked/skcom.ftni : integer iwscn
// ../sked/prset.f : integer fc_gwinsz; iwscn = fc_gwinsz()

#include <termio.h>

#ifdef _NEEDED
int fc_gwinw_()
#else
int fc_gwinw()
#endif
{
     struct winsize ws;

     ioctl(0,TIOCGWINSZ,&ws);
     return((int) ws.ws_col);
}
