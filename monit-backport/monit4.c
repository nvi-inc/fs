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
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include <ctype.h>
#include <stdlib.h>
#include "mparm.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

/* function prototypes */
void setup_ids();
int nsem_test();
void rte_time();

int main()
{
  int it[6], iyear, isleep;
  int mode = 0;
  char ch;

  int m4init();
  int mout4();
  void die4();
  unsigned rte_sleep();

  setup_ids();

/*  First check to see if the field system is running */

  if (nsem_test(NSEMNAME) != 1) {
    printf("Field System not running\n");
    exit(0);
  }

  shm_addr->m_das = 0;
  nsem_take("mont4");

  initscr();
  signal(SIGINT, die4);
  cbreak();
  noecho ();
  nodelay(stdscr, TRUE);

  curs_set(0);
  clear();
  curs_set(0);
  refresh();

/*  Initialize the display window */

  while(1) {
    m4init(shm_addr->m_das,mode);
    mout4(shm_addr->m_das,mode);
    refresh();
    rte_time(it,&iyear);
    isleep=100-it[0];
    isleep=isleep>100?100:isleep;
    isleep=isleep<1?100:isleep;
    rte_sleep((unsigned) isleep);
    if (nsem_test(NSEMNAME) != 1) {
      printf("Field System terminated\n");
      die4();
      exit(0);
    }
    while(ERR!=(ch=getch()))
      if (isdigit(ch)) {
        shm_addr->m_das = (ch - '0' - 1)/2;
        mode = (ch - '0' - 1)%2;
      } else if (ch=='q' || ch=='Q') {
        printf("Exit requested\n");
        die4();
        exit(0);
      }
    if (shm_addr->m_das >= shm_addr->n_das) shm_addr->m_das = shm_addr->n_das-1;
  }

}  /* end main of monit4 */
