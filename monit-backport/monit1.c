/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/*  Field System time */
#include <ncurses.h>
#include <signal.h>
#include "mparm.h"
#include <sys/types.h>
#include <stdlib.h>
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
  cbreak();
  noecho ();
  nodelay(stdscr, TRUE);

  curs_set(0);
  clear();
  refresh();

  m1init();

  while(1) {
    while(ERR!=getch())
      ;
    move(ROW1,COL1+16);
    rte_time(it,&iyear);
    move(ROW1,COL1+16);
    /* not Y10K compliant */
    printw("%d.%.3d.%.2d:%.2d:%.2d",iyear,it[4],it[3],it[2],
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
