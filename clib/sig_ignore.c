#include <sys/types.h>
#include <signal.h>

void sig_ignore()
{

                       /* ignore signals that might accidently abort */
    if (-1==sigignore(SIGINT)) {
      perror("sig_ignore: ignoring SIGINT");
      exit(-1);
    }

    if (-1==sigignore(SIGQUIT)) {
      perror("sig_ignore: ignoring SIGQUIT");
      exit(-1);
    }
}
