#include <termios.h>

int portoutdrain(port)
int *port;
/* portoutdrain waits for the output queue to drain for this port */
{
  if(0!=tcdrain( *port))
    return(-1);

  return 0;
}
