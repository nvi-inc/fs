/*                                                                */
/*  HISTORY:                                                      */
/*  WHO  WHEN    WHAT                                             */
/*  gag  920714  Added a check for Mark IV rack and drive to      */
/*               to go along with Mark III rack and drive.        */
/*                                                                */
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include "mparm.h"
#include "dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

main()
{
  int it[6], iyear, isleep;

  int m2init();
  int mout2();
  void die();
  unsigned rte_sleep();

  setup_ids();

/*  First check to see if the field system is running */

  if (nsem_test(NSEMNAME) != 1) {
    printf("Field System not running\n");
    exit(0);
  }

  initscr();
  signal(SIGINT, die);
  noecho ();
  nodelay(stdscr, TRUE);

  curs_set(0);
  clear();
  curs_set(0);
  refresh();

/*  Initialize the display window */

  m2init();

  while(1) {
    while(ERR!=getch())
      ;
    rte_time(it,&iyear);
    mout2(it,iyear);
    move(ROW1,COL1+16);
    printw("%d-%.3d %.2d:%.2d:%.2d",iyear,it[4],it[3],it[2],
            it[1]);
    move(ROW1,COL1+33);
    refresh();
    rte_time(it,&iyear);
    isleep=100-it[0];
    isleep=isleep>100?100:isleep;
    isleep=isleep<1?100:isleep;
    rte_sleep((unsigned) isleep);
    if (nsem_test(NSEMNAME) != 1) {
      printf("Field System terminated\n");
      die();
      exit(0);
    }
  }

}  /* end main of monit2 */
