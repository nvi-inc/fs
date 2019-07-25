/*  Field System time */
#include <ncurses.h>
#include <signal.h>
#include "mparm.h"
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;
main()
{
  int it[5];
  int iyear;
  int isleep;
  void die();
  int m1init();
  int nsem_test();
  int nsemret;
  unsigned rte_sleep();

  setup_ids();

  if (nsem_test(NSEMNAME) != 1) {
    printf("Field System not running\n");
    exit(0);
  }

  initscr(); /* the first routine called should almost always be initscr */

  signal(SIGINT, die);
  curs_set(0);
  clear();
  refresh();

  m1init();

  while(1) {
    move(ROW1,COL1+16);
    rte_time(it,&iyear);
    move(ROW1,COL1+16);
    printw("%d-%.3d %.2d:%.2d:%.2d",iyear,it[4],it[3],it[2],
            it[1]);
    move(ROW1,COL1+36);
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

}

m1init()
{
    move(ROW1,COL1);
    standout();
    printw("%.8s",shm_addr->lnaant);
    standend();
    mvaddstr(ROW1,COL1+34,"UT"); 

    refresh();
}
