#include <ncurses.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <stdlib.h>
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
  cbreak();
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
  int j, iend;
  char outarr[80];
  char *outpt;
  void preint();

  outpt = &outarr[0];
  standout();
  mvaddstr(ROW1,COL1,"Tsys");
  if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4) {
    mvaddstr(ROW1,COL1+13,"(IFA)");
    mvaddstr(ROW1,COL1+26,"(IFB)");
    mvaddstr(ROW1+1,COL1+13,"(IFC)");
    mvaddstr(ROW1+1,COL1+26,"(IFD)");
    mvaddstr(ROW1+2,COL1,"BBC");
  } else if(shm_addr->equip.rack == DBBC) {
    mvaddstr(ROW1,COL1+13,"(IFA)");
    if(shm_addr->dbbc_cond_mods > 1)
      mvaddstr(ROW1,COL1+26,"(IFB)");
    if(shm_addr->dbbc_cond_mods > 2)
      mvaddstr(ROW1+1,COL1+13,"(IFC)");
    if(shm_addr->dbbc_cond_mods > 3)
      mvaddstr(ROW1+1,COL1+26,"(IFD)");
    mvaddstr(ROW1+2,COL1,"BBC");
  } else if(shm_addr->equip.rack == LBA || shm_addr->equip.rack == LBA4) {
    mvaddstr(ROW1+2,COL1+1,"IFP");
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
    if ((shm_addr->equip.rack == LBA || shm_addr->equip.rack == LBA4) 
        && j > 2*shm_addr->n_das) break;
    move(ROW1+2+j,COL1+1);
    preint(outpt,j,-2,1);
    printw("%s",outarr);
  }
  iend=14;
  if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4)
    iend=MAX_VLBA_BBC;
  if(shm_addr->equip.rack == DBBC)
    iend=MAX_DBBC_BBC;
  for(j=15;j<=iend;j++) {
    move(ROW1+2+j,COL1+1);
    preint(outpt,j,-2,1);
    printw("%s",outarr);
  }
  refresh();
}

mout3()

{
  int i,j,k;
  char freq[9];
  char *ptfreq;
  char outarr[80];
  char *outpt;
  void preflt();

    outpt = &outarr[0];
    ptfreq= &freq[0];

    if(shm_addr->equip.rack != LBA  && shm_addr->equip.rack != LBA4 &&
       shm_addr->equip.rack != VLBA && shm_addr->equip.rack != VLBA4 &&
       shm_addr->equip.rack != DBBC) {
      move(ROW1,COL1+7);
      preflt(outpt,shm_addr->systmp[28],-5,1);
      printw("%s",outarr);

      move(ROW1,COL1+20);
      preflt(outpt,shm_addr->systmp[29],-5,1);
      printw("%s",outarr);

      move(ROW1+1,COL1+7);
      preflt(outpt,shm_addr->systmp[30],-5,1);
      printw("%s",outarr);
    } else if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4 ) {
      move(ROW1,COL1+7);
      preflt(outpt,shm_addr->systmp[2*MAX_BBC+0],-5,1);
      printw("%s",outarr);

      move(ROW1,COL1+20);
      preflt(outpt,shm_addr->systmp[2*MAX_BBC+1],-5,1);
      printw("%s",outarr);

      move(ROW1+1,COL1+7);
      preflt(outpt,shm_addr->systmp[2*MAX_BBC+2],-5,1);
      printw("%s",outarr);

      move(ROW1+1,COL1+20);
      preflt(outpt,shm_addr->systmp[2*MAX_BBC+3],-5,1);
      printw("%s",outarr);
    } else if(shm_addr->equip.rack == DBBC) {
      move(ROW1,COL1+7);
      preflt(outpt,shm_addr->systmp[2*MAX_DBBC_BBC+0],-5,1);
      printw("%s",outarr);

      if(shm_addr->dbbc_cond_mods > 1) {
	move(ROW1,COL1+20);
	preflt(outpt,shm_addr->systmp[2*MAX_DBBC_BBC+1],-5,1);
	printw("%s",outarr);
      }

      if(shm_addr->dbbc_cond_mods > 2) {
	move(ROW1+1,COL1+7);
	preflt(outpt,shm_addr->systmp[2*MAX_DBBC_BBC+2],-5,1);
	printw("%s",outarr);
      }

      if(shm_addr->dbbc_cond_mods > 3) {
	move(ROW1+1,COL1+20);
	preflt(outpt,shm_addr->systmp[2*MAX_DBBC_BBC+3],-5,1);
	printw("%s",outarr);
      }
    }

    for (i=1;i<=MAX_BBC;i++) {
      if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4) {
        long bbc2freq(),freqv;
	if(MAX_VLBA_BBC < i)
	  continue;
        freqv=bbc2freq(shm_addr->bbc[i-1].freq);
        snprintf(ptfreq,sizeof(freq)," %7.2f",(float)freqv/100);
      } else if(shm_addr->equip.rack == LBA || shm_addr->equip.rack == LBA4) {
        if (i > 2*shm_addr->n_das) break;
        snprintf(ptfreq,sizeof(freq),"%-06.2lf",shm_addr->das[(i-1)/2].ifp[(i-1)%2].frequency);
      } else if(shm_addr->equip.rack == DBBC) {
	if(MAX_DBBC_BBC < i)
	  continue;
	snprintf(ptfreq,sizeof(freq),"%7.2f",
		 ((float)(shm_addr->dbbcnn[i-1].freq/10000)/100));
      } else {
	if(14 < i)
	  continue;
        k = (i-1)*6;
	ptfreq[0]=' ';
        memcpy(ptfreq+1,shm_addr->lfreqv+k,6);
	ptfreq[7]=0;
      }
      move(ROW1+2+i,COL1+5);
      printw("%7s",ptfreq);
      if(shm_addr->equip.rack == DBBC &&
	 shm_addr->dbbcnn[i-1].freq%10000 !=0)
	printw("+");
      else
	printw(" ");
      move(ROW1+2+i,COL1+15);
      if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4 ||
	 shm_addr->equip.rack == DBBC) 
	preflt(outpt,shm_addr->systmp[i+MAX_BBC-1],-6,1);
      else
	preflt(outpt,shm_addr->systmp[i+13],-6,1);
      printw("%s",outarr);
      move(ROW1+2+i,COL1+23);
      if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4 ||
	 shm_addr->equip.rack == DBBC) 
	preflt(outpt,shm_addr->systmp[i-1],-6,1);
      else
	preflt(outpt,shm_addr->systmp[i-1],-6,1);
      printw("%s",outarr);
    }
  refresh();
}
