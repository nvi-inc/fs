#include <ncurses.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include "mparm.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

main()
{
  int it[5];
  int iyear;

  int m3init();
  int mout3();
  void die();
  unsigned rte_sleep();

  setup_ids();

  if (nsem_test(NSEMNAME) != 1) {
    printf("Field System not running\n");
    exit(0);
  }

  initscr();
  signal(SIGINT, die);
  noecho ();
  nodelay(stdscr, TRUE);

  clear();
  refresh();

  m3init();

  while(1) {
    while(ERR!=getch())
      ;
    mout3();
    rte_sleep(100);
    if (nsem_test(NSEMNAME) != 1) {
      printf("Field System terminated\n");
      die();
      exit(0);
    }
  }

}

m3init()
{
  int j;
  char outarr[80];
  char *outpt;
  void preint();

  outpt = &outarr[0];
  standout();
  mvaddstr(ROW1,COL1,"Tsys");
  if(shm_addr->equip.rack == VLBA) {
    mvaddstr(ROW1,COL1+13,"(IFA)");
    mvaddstr(ROW1,COL1+26,"(IFB)");
    mvaddstr(ROW1+1,COL1+13,"(IFC)");
    mvaddstr(ROW1+1,COL1+26,"(IFD)");
    mvaddstr(ROW1+2,COL1,"BBC");
  } else {
    mvaddstr(ROW1,COL1+13,"(IF1)");
    mvaddstr(ROW1,COL1+26,"(IF2)");
    mvaddstr(ROW1+1,COL1+13,"(IF3)");
    mvaddstr(ROW1+2,COL1+1,"VC");
  }

  mvaddstr(ROW1+2,COL1+7,"Freq"); 
  mvaddstr(ROW1+2,COL1+16,"Ts-U");
  mvaddstr(ROW1+2,COL1+24,"Ts-L");
  standend();

  for(j=1;j<=14;j++) {
    move(ROW1+2+j,COL1+1);
    preint(outpt,j,-2,1);
    printw("%s",outarr);
  }
  refresh();
}

mout3()

{
  int i,j,k;
  char freq[6];
  char *ptfreq;
  char outarr[80];
  char *outpt;
  void preflt();

    outpt = &outarr[0];
    ptfreq= &freq[0];

    move(ROW1,COL1+7);
    preflt(outpt,shm_addr->systmp[28],-5,1);
    printw("%s",outarr);

    move(ROW1,COL1+20);
    preflt(outpt,shm_addr->systmp[29],-5,1);
    printw("%s",outarr);

    move(ROW1+1,COL1+7);
    preflt(outpt,shm_addr->systmp[30],-5,1);
    printw("%s",outarr);

    if(shm_addr->equip.rack == VLBA) {
      move(ROW1+1,COL1+20);
      preflt(outpt,shm_addr->systmp[31],-5,1);
      printw("%s",outarr);
    }

    for (i=1;i<=14;i++) {
      move(ROW1+2+i,COL1+6);
      if(shm_addr->equip.rack == VLBA) {
        long bbc2freq(),freq;
        freq=bbc2freq(shm_addr->bbc[i-1].freq);
        sprintf(ptfreq,"%-06.2f",(float)freq/100);
      } else {
        k = (i-1)*6;
        memcpy(ptfreq,shm_addr->lfreqv+k,6);
      }
      printw("%.6s",ptfreq);
      move(ROW1+2+i,COL1+15);
      preflt(outpt,shm_addr->systmp[i+13],-6,1);
      printw("%s",outarr);
      move(ROW1+2+i,COL1+23);
      preflt(outpt,shm_addr->systmp[i-1],-6,1);
      printw("%s",outarr);
    }
  refresh();
}
