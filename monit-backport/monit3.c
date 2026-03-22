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
    if(shm_addr->equip.rack_type == DBBC_DDC ||
       shm_addr->equip.rack_type == DBBC_DDC_FILA10G)
      mvaddstr(ROW1+2,COL1,"BBC");
  } else if(shm_addr->equip.rack == LBA || shm_addr->equip.rack == LBA4) {
    mvaddstr(ROW1+2,COL1+1,"IFP");
  } else {
    mvaddstr(ROW1,COL1+13,"(IF1)");
    mvaddstr(ROW1,COL1+26,"(IF2)");
    mvaddstr(ROW1+1,COL1+13,"(IF3)");
    mvaddstr(ROW1+2,COL1+1,"VC");
  }

  if(shm_addr->equip.rack != DBBC ||
     (shm_addr->equip.rack_type != DBBC_PFB &&
      shm_addr->equip.rack_type != DBBC_PFB_FILA10G)) {
    mvaddstr(ROW1+2,COL1+7,"Freq"); 
    mvaddstr(ROW1+2,COL1+16,"Ts-U");
    mvaddstr(ROW1+2,COL1+24,"Ts-L");
  } else {
    mvaddstr(ROW1+2,COL1,"vsi1");
    mvaddstr(ROW1+2,COL1+5,"Freq"); 
    mvaddstr(ROW1+2,COL1+12,"Ts");
    mvaddstr(ROW1+2,COL1+17,"vsi2");
    mvaddstr(ROW1+2,COL1+22,"Freq"); 
    mvaddstr(ROW1+2,COL1+29,"Ts");
  }    
  standend();

  if(shm_addr->equip.rack != DBBC || 
     (shm_addr->equip.rack == DBBC &&
     (shm_addr->equip.rack_type == DBBC_DDC ||
      shm_addr->equip.rack_type == DBBC_DDC_FILA10G))) {
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
  int ifs[4];

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
    }

 BBCS:
    if(shm_addr->equip.rack != DBBC ||
       (shm_addr->equip.rack == DBBC &&
	  (shm_addr->equip.rack_type == DBBC_DDC ||
	   shm_addr->equip.rack_type == DBBC_DDC_FILA10G))) {
      int itpis[MAX_GLOBAL_DET];
      int ifreq[MAX_BBC];

      for(i=0;i<MAX_BBC;i++)
	itpis[i]=itpis[i+MAX_BBC]=ifreq[i]=0;
      mk5dbbcd(itpis); 

      for(i=0;i<4;i++)
	ifs[i]=0;

      for (i=1;i<=MAX_BBC;i++) {
	if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4) {
	  int bbc2freq(),freqv;
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
	  if(0!=shm_addr->dbbcnn[i-1].freq) {
	    ifreq[i-1]=1;
	    snprintf(ptfreq,sizeof(freq),"%7.2f",
		     ((float)(shm_addr->dbbcnn[i-1].freq/10000)/100));
	  } else
	    strcpy(ptfreq,"       ");
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
	if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4)
	  preflt(outpt,shm_addr->systmp[i+MAX_BBC-1],-6,1);
	else if (shm_addr->equip.rack == DBBC) {
	  if(itpis[i+MAX_BBC-1] && ifreq[i-1]) {
	    if(shm_addr->dbbcnn[i-1].source >=0 && /* just being save */
	       shm_addr->dbbcnn[i-1].source < shm_addr->dbbc_cond_mods)
	      ifs[shm_addr->dbbcnn[i-1].source]=1;
	    preflt(outpt,shm_addr->systmp[i+MAX_BBC-1],-6,1);
	  } else
	    strcpy(outpt,"      ");
	} else
	  preflt(outpt,shm_addr->systmp[i+13],-6,1);
	printw("%s",outarr);

	move(ROW1+2+i,COL1+23);
	if(shm_addr->equip.rack == VLBA || shm_addr->equip.rack == VLBA4)
	  preflt(outpt,shm_addr->systmp[i-1],-6,1);
	else if(shm_addr->equip.rack == DBBC) {
	  if(itpis[i-1] && ifreq[i-1]) {
	    if(shm_addr->dbbcnn[i-1].source >=0 && /* just being save */
	       shm_addr->dbbcnn[i-1].source < shm_addr->dbbc_cond_mods)
	      ifs[shm_addr->dbbcnn[i-1].source]=1;
	    preflt(outpt,shm_addr->systmp[i-1],-6,1);
	  } else
	    strcpy(outpt,"      ");
	} else
	  preflt(outpt,shm_addr->systmp[i-1],-6,1);
	printw("%s",outarr);
      }
    } else if (shm_addr->equip.rack == DBBC &&
	       (shm_addr->equip.rack_type == DBBC_PFB ||
		shm_addr->equip.rack_type == DBBC_PFB_FILA10G)) {
      int i, core, ifc, chan, ik, zone, filter;
      char  output[4];
      float freqv;

      static char letters[ ]=" abcd";
      static int zone_table[] = {2, 1, 4,3}; /* DBBC filter Nyquist zones */
      static char sb[ ]= "lu";

      for(i=0;i<4;i++)
	ifs[i]=0;

      for(i=0;i<16;i++) {

	/* vsi1 */
	move(ROW1+3+i,COL1);
	clrtoeol();

	core=shm_addr->dbbc_vsix[0].core[i];
	ifc=1;

	ik=shm_addr->dbbc_vsix[0].chan[i]+(core-1)*16;
	if(core>0) {
	  for(j=1;j<=shm_addr->dbbc_cond_mods &&
		core>shm_addr->dbbc_como_cores[j-1];j++) {
	    ifc+=1;
	    core-=shm_addr->dbbc_como_cores[j-1];
	  }

	  /* core is now core on this IF */
	  chan=shm_addr->dbbc_vsix[0].chan[i]+(core-1)*16;
	  snprintf(output,4,"%c%02d",letters[ifc],chan);
	  move(ROW1+3+i,COL1);
	  printw("%s",output);

	  freqv=(chan%16)*32-16; /* center */
	  filter=shm_addr->dbbcifx[ifc-1].filter;

	  if(filter < 1 || filter>4)
	    continue;

	  zone=zone_table[filter-1];
	  if(1==zone%2) /*odd zone */
	    freqv=(zone-1)*512+freqv;
	  else /* even */
	    freqv=zone*512-freqv;
	  snprintf(ptfreq,sizeof(freq)," %4.0f%c",freqv,sb[zone%2]);
	  move(ROW1+3+i,COL1+3);
	  printw("%5s",ptfreq); 
	  
	  if(shm_addr->mk5b_mode.mask.state.known == 0 ||
	     shm_addr->dbbcform.mode!=0)
	    continue;
	  
	  if(!(shm_addr->mk5b_mode.mask.mask & (0x3ULL << (i*2))))
	    continue;
	  
	  ifs[ifc-1]=1;
	  move(ROW1+3+i,COL1+10);
	  preflt(outpt,shm_addr->systmp[ik],-5,1);
	  printw("%s",outpt);
	}
      }
      for(i=0;i<16;i++) {

	/* vsi2 */

	core=shm_addr->dbbc_vsix[1].core[i];
	ifc=1;
	ik=shm_addr->dbbc_vsix[1].chan[i]+(core-1)*16;
	if(core>0) {
	  for(j=1;j<=shm_addr->dbbc_cond_mods &&
		core>shm_addr->dbbc_como_cores[j-1];j++) {
	    ifc+=1;
	    core-=shm_addr->dbbc_como_cores[j-1];
	  }

	  /* core is now core on this IF */
	  chan=shm_addr->dbbc_vsix[1].chan[i]+(core-1)*16;
	  snprintf(output,4,"%c%02d",letters[ifc],chan);
	  move(ROW1+3+i,COL1+17);
	  printw("%s",output);

	  freqv=(chan%16)*32-16; /* center */
	  filter=shm_addr->dbbcifx[ifc-1].filter;

	  if(filter < 1 || filter>4)
	    continue;

	  zone=zone_table[filter-1];
	  if(1==zone%2) /*odd zone */
	    freqv=(zone-1)*512+freqv;
	  else /* even */
	    freqv=zone*512-freqv;
	  snprintf(ptfreq,sizeof(freq)," %4.0f%c",freqv,sb[zone%2]);
	  move(ROW1+3+i,COL1+20);
	  printw("%5s",ptfreq); 

	  if(shm_addr->mk5b_mode.mask.state.known == 0 ||
	     shm_addr->dbbcform.mode!=0)
	    continue;
	  
	  if(!(shm_addr->mk5b_mode.mask.mask & (0x3ULL << (32+i*2))))
	    continue;
	  
	  ifs[ifc-1]=1;
	  move(ROW1+3+i,COL1+27);
	  preflt(outpt,shm_addr->systmp[ik],-5,1);
	  printw("%s",outpt);
	}

      }
    }
    if(shm_addr->equip.rack == DBBC) {
      int istart;

      if (shm_addr->equip.rack_type == DBBC_DDC ||
	  shm_addr->equip.rack_type == DBBC_DDC_FILA10G)
	istart=2*MAX_DBBC_BBC;
      else if (shm_addr->equip.rack_type == DBBC_PFB ||
	       shm_addr->equip.rack_type == DBBC_PFB_FILA10G)
	istart=MAX_DBBC_PFB;
      else
	goto END;

      move(ROW1,COL1+7);
      if(ifs[0]) {
	preflt(outpt,shm_addr->systmp[istart+0],-5,1);
	printw("%s",outarr);
      }	else
	printw("%s","     ");

      if(shm_addr->dbbc_cond_mods > 1) {
	move(ROW1,COL1+20);
	if(ifs[1]) {
	  preflt(outpt,shm_addr->systmp[istart+1],-5,1);
	  printw("%s",outarr);
	} else
	  printw("%s","     ");
      }

      if(shm_addr->dbbc_cond_mods > 2) {
	move(ROW1+1,COL1+7);
	if(ifs[2]) {
	  preflt(outpt,shm_addr->systmp[istart+2],-5,1);
	  printw("%s",outarr);
	} else
	  printw("%s","     ");
      }

      if(shm_addr->dbbc_cond_mods > 3) {
	move(ROW1+1,COL1+20);
	if(ifs[3]) {
	  preflt(outpt,shm_addr->systmp[istart+3],-5,1);
	  printw("%s",outarr);
	} else
	  printw("%s","     ");
      }
    }
 END:
    move(ROW1+4,COL1);
    curs_set(0);
    refresh();
}
