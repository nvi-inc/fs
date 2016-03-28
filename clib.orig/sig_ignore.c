#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>

void sig_ignore()
{

                       /* ignore signals that might accidently abort */
    if (SIG_ERR==signal(SIGINT,SIG_IGN)) {
      perror("sig_ignore: ignoring SIGINT");
      exit(-1);
    }

    if (SIG_ERR==signal(SIGQUIT,SIG_IGN)) {
      perror("sig_ignore: ignoring SIGQUIT");
      exit(-1);
    }
}
