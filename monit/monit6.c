/* monit6 -- RDBE monitor program
 */
#include <ncurses.h>
#include <stdlib.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>

#include "../../fs/include/dpi.h"
#include "../../fs/include/params.h"
#include "../../fs/include/fs_types.h"
#include "../../fs/include/fscom.h"
#include "../../fs/include/shm_addr.h"

#include "mon6.h"

struct fscom *fs;

void resize()
{
  clear();
  m6init();
  refresh();
}
main()
{
  int it[6], iyear, isleep;
  int m6init();
  int m6out();
  void die();
  void resize();
  unsigned rte_sleep();

  setup_ids();
  fs = shm_addr;

/*  First check to see if the field system is running */

  if (nsem_test("fs   ") != 1) {
    printf("monit6 terminating, Field System not running\n");
    exit(0);
  }

  initscr();
  signal(SIGINT, die);
  signal(SIGWINCH, resize);
  noecho ();
  nodelay(stdscr, TRUE);

  curs_set(0);
  clear();
  refresh();

/*  Initialize the display window */

  m6init();

  while(1) {
    while(ERR!=getch())
      ;

    mout6();
    move(ROW_HOLD,COL_HOLD);  /* place cursor at consistent location */

    refresh();

    rte_time(it,&iyear);
    isleep=120-it[0];
    isleep=isleep>100?100:isleep;
    isleep=isleep<1?100:isleep;
    rte_sleep((unsigned) isleep);

    if (nsem_test("fs   ") != 1) {
      printf("Field System terminated\n");
      die();
      exit(0);
    }
  }

}  /* end main of monit6 */
