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
#include <stdlib.h>
#include <sys/ioctl.h> 
#include "mparm.h"
#include "dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;
int kMrack, kMdrive[2], kS2drive[2],kVrack,kVdrive[2],kM3rack,kM4rack,kV4rack,
  kLrack,kK4drive[2],kK41drive_type[2],kK42drive_type[2], kDrack, selectm;

volatile sig_atomic_t need_redraw = false; 
static void
sigwinch_handler(int sig) {
	need_redraw = true;
}

main()
{
  int it[6], iyear, isleep;
  int rack,drive,drive_type,i,select_old;

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

  rack=shm_addr->equip.rack;
  kMrack=rack==MK3 || rack==MK4;
  kM3rack=rack==MK3;
  kM4rack=rack==MK4;
  kVrack=rack==VLBA;
  kV4rack=rack==VLBA4;
  kLrack=rack==LBA || rack==LBA4;
  kDrack=rack==DBBC;

  for (i=0;i<2;i++) {
    drive=shm_addr->equip.drive[i];
    drive_type=shm_addr->equip.drive_type[i];
    kMdrive[i]=drive==MK3 || drive==MK4;
    kVdrive[i]=drive==VLBA || drive==VLBA4;
    kS2drive[i]=drive==S2;
    kK4drive[i]=drive==K4;
    if(kK4drive[i]) {
      kK41drive_type[i]=drive_type=K41||drive_type==K41DMS;
      kK42drive_type[i]=drive_type=K42||drive_type==K42DMS;
    }
  }

  initscr();
  signal(SIGINT, die);
  signal(SIGWINCH, sigwinch_handler);
  cbreak();
  noecho ();
  nodelay(stdscr, TRUE);

  curs_set(0);
  clear();
  curs_set(0);
  refresh();

  selectm=shm_addr->select;
  m2init();
  select_old=selectm;

/*  Initialize the display window */

  while(1) {
    if (need_redraw) {
      struct winsize ws;

      if (ioctl(0, TIOCGWINSZ, &ws) == -1) {
	perror("error getting window size");
        exit(1);
      }

      resizeterm(ws.ws_row, ws.ws_col);
      wresize(stdscr, ws.ws_row, ws.ws_col);
      clear();
      curs_set(0);
      refresh();

      selectm=shm_addr->select;
      m2init();
      select_old=selectm;
      need_redraw = false;
    }

    while(ERR!=getch())
      ;
    selectm=shm_addr->select;
    if(select_old!=selectm) {
      m2init();
      select_old=selectm;
    }

    rte_time(it,&iyear);
    mout2(it,iyear);
    move(ROW1,COL1+16);
    /* not Y10K compliant */
    printw("%d.%.3d.%.2d:%.2d:%.2d",iyear,it[4],it[3],it[2],
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
