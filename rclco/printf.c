#ifdef UNIX

#include "main.h"
#include "lib.h"

/** We re-define printf to work with curses! This means you can't use printf
      until curses is initialized! **/
int printf(const char* format, int arg1, int arg2, int arg3,
                               int arg4, int arg5, int arg6)
{
   return(cprintf(format,arg1,arg2,arg3,arg4,arg5,arg6));
}

#endif  /* UNIX */
