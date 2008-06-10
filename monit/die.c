#include <signal.h>
#include <stdlib.h>

void die(i)
int i;
{
  signal(SIGINT, SIG_IGN);
  mvcur(0,0, 1, 5);
  endwin();
  exit(0);
}
