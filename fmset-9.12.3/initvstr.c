/* initvstr.c - initialize VLBA strings */

#include <memory.h>
#include "../include/params.h"

char setcmd[] =  {0,'f','m',0x00,0xa8,0x00,0x00,  /* time years */
                  0,'f','m',0x00,0xa9,0x00,0x00,  /* time days  */
                  0,'f','m',0x00,0xaa,0x00,0x00,  /* time hours */
                  0,'f','m',0x00,0xab,0x00,0x00}; /* time min, sec */

void initvstr()
{
/* initialize command strings with formatter mnemonic */
memcpy (setcmd+ 1, DEV_VFM, 2);
memcpy (setcmd+ 8, DEV_VFM, 2);
memcpy (setcmd+15, DEV_VFM, 2);
memcpy (setcmd+22, DEV_VFM, 2);
}
