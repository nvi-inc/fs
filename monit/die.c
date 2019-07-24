#include <signal.h>

die()
{
  signal(SIGINT, SIG_IGN);
  mvcur(0,0, 1, 5);
  endwin();
  exit(0);
}
