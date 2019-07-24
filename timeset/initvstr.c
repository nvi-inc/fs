/* initvstr.c - initialize VLBA strings */

#include <memory.h>
#include "../include/params.h"

char timecmd[] = {5,'f','m',0x00,0x28, /* time years */
                  5,'f','m',0x00,0x29, /* time days  */
                  5,'f','m',0x00,0x2a, /* time hours */
                  5,'f','m',0x00,0x2b, /* time minutes and seconds */
                  5,'f','m',0x00,0x28,
                  5,'f','m',0x00,0x29,
                  5,'f','m',0x00,0x2a,
                  5,'f','m',0x00,0x2b};

char setcmd[] =  {0,'f','m',0x00,0xa8,0x00,0x00,  /* time years */
                  0,'f','m',0x00,0xa9,0x00,0x00,  /* time days  */
                  0,'f','m',0x00,0xaa,0x00,0x00,  /* time hours */
                  0,'f','m',0x00,0xab,0x00,0x00}; /* time min, sec */

void initvstr()
{
/* initialize command strings with formatter mnemonic */
memcpy (timecmd+ 1, DEV_VFM, 2);
memcpy (timecmd+ 6, DEV_VFM, 2);
memcpy (timecmd+11, DEV_VFM, 2);
memcpy (timecmd+16, DEV_VFM, 2);
memcpy (timecmd+21, DEV_VFM, 2);
memcpy (timecmd+26, DEV_VFM, 2);
memcpy (timecmd+31, DEV_VFM, 2);
memcpy (timecmd+36, DEV_VFM, 2);
memcpy (setcmd+ 1, DEV_VFM, 2);
memcpy (setcmd+ 8, DEV_VFM, 2);
memcpy (setcmd+15, DEV_VFM, 2);
memcpy (setcmd+22, DEV_VFM, 2);
}
