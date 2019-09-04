/* monit6 -- RDBE monitor program
 */
#include <ncurses.h>
#include <stdlib.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "mon6.h"

struct fscom *fs;

int kr2dbe;

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
  char buff[128];

  setup_ids();
  fs = shm_addr;

/*  First check to see if the field system is running */

  if (nsem_test("fs   ") != 1) {
    printf("monit6 terminating, Field System not running\n");
    sleep(10);
    exit(-1);
  }

  kr2dbe=shm_addr->equip.rack==RDBE
    && shm_addr->equip.rack_type==R2DBE;

  strcpy(buff,FS_ROOT);
  strncat(buff,"/control/monit6.ctl",sizeof(buff)-strlen(buff)-1);
  if(gmonit6(buff,&fs->monit6)) {
    printf("error reading %s, see log for error\n", buff);
    sleep(10);
    exit(-1);
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
