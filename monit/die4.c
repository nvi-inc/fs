#include <signal.h>

void die4(i)
int i;
{
  signal(SIGINT, SIG_IGN);
  mvcur(0,0, 1, 5);
  endwin();
  nsem_put("mont4");
  exit(0);
}
