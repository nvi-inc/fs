#ifdef UNIX

#include "main.h"
#include "lib.h"

/** We re-define printf to work with curses! This means you can't use printf
      until curses is initialized! **/
int printf(const char* format, long int arg1, long int arg2, long int arg3,
                               long int arg4, long int arg5, long int arg6)
{
   return(cprintf(format,arg1,arg2,arg3,arg4,arg5,arg6));
}

#endif  /* UNIX */
