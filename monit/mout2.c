/*                                                                */
/*  HISTORY:                                                      */
/*  WHO  WHEN    WHAT                                             */
/*  gag  920714  Added a check for Mark IV rack and drive to      */
/*               to go along with Mark III rack and drive.        */
/*  nrv  921027  Added check for special source names             */
/*                                                                */
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <string.h>
#include <sys/types.h>
#include "mparm.h"
#include "dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

                                             /* parameter keywords */
static char *key_mode[ ]={ "prn", "v"  , "m"  , "a"  , "b"  , "c"  ,
			   "b1" , "b2" , "c1" , "c2" ,
                           "d1" , "d2" , "d3" , "d4" , "d5" , "d6" , "d7" ,
                           "d8" , "d9" , "d10", "d11", "d12", "d13", "d14",
                           "d15", "d16", "d17", "d18", "d19", "d20", "d21",
                           "d22", "d23", "d24", "d25", "d26", "d27", "d28"};
#define NKEY_MODE sizeof(key_mode)/sizeof( char *)

extern struct fscom *shm_addr;

mout2(it,iyear)

int it[6];
int iyear;

{
  int idum;
  int i, sv, k, icr;
  int irah,iram,idecd,idecm;
  int kMrack, kMdrive;
  int itemp, ivalue;
  unsigned int iversion;
  double azim={0.0},elev={0.0};
  double ha={0.0},dc,az,el;
  float outhaa={0.0};
  double xxx={0.0},yyy={0.0};
  float outxxx={0.0},outyyy={0.0};
  float ras;
  double dtemp, htemp;
  char feet[6];
  char dig[3];
  char outfloat[80];
  char *outf; 
  char checkarr[91];
  char *checkln; 
  char *ptfeet;
  int posdeg;
  double raxx,dcxx;
  void preflt();
  void preint();
  int len;

  kMrack = 0;
  kMdrive = 0;
  itemp=shm_addr->equip.rack;
  if ((itemp & 0x01) || (itemp & 0x04)) kMrack=1;
  itemp=shm_addr->equip.drive;
  if ((itemp & 0x01) || (itemp & 0x04)) kMdrive=1;

  ptfeet = &feet[0];
  checkln = &checkarr[0];
  outf = &outfloat[0];

/* ROW 1 */

  move(ROW1,COL1+0);
  standout();
  printw("%.8s",shm_addr->lnaant);
  standend();

  if (shm_addr->KHALT!=0) {            /* schedule halted */
    if(it[1]%2==0)
	standout();
    mvaddstr(ROW1,COL1+40,"HALT"); 
    if(it[1]%2==0)
	standend();
  } else mvaddstr(ROW1,COL1+40,"    "); 

  move(ROW1,COL1+55);
  preflt(outf,shm_addr->tempwx,-5,1);
  printw("%s",outfloat);
  move(ROW1,COL1+62);
  standout();
  printw("%.10s",shm_addr->lsorna);
  posdeg = 0;
  if (memcmp(shm_addr->lsorna,"azel      ",10)==0 ||
      memcmp(shm_addr->lsorna,"azeluncr  ",10)==0 ) {
    posdeg = 1; 
    /* Convert az/el in common to actual ra/dec */
    cnvrt(2,shm_addr->radat,shm_addr->decdat,&raxx,&dcxx,it,
        shm_addr->alat,shm_addr->wlong);
   } else if (memcmp(shm_addr->lsorna,"stow      ",10)==0 ||
              memcmp(shm_addr->lsorna,"service   ",10)==0 ||
              memcmp(shm_addr->lsorna,"hold      ",10)==0 ||
              memcmp(shm_addr->lsorna,"disable   ",10)==0 ||
              memcmp(shm_addr->lsorna,"idle      ",10)==0 ||
              memcmp(shm_addr->lsorna,"          ",10)==0)  {
    posdeg = 1; 
    raxx = 0.0;
    dcxx = 0.0;
   } else if (memcmp(shm_addr->lsorna,"xy        ",10)==0) {
    posdeg = 1; 
    /* Convert x/y in common to actual ra/dec */
    cnvrt(7,shm_addr->radat,shm_addr->decdat,&raxx,&dcxx,it,
        shm_addr->alat,shm_addr->wlong);
   }
  standend();
  move(ROW1,COL1+73);
  if (shm_addr->ionsor == 0)
    printw("SLEWING ");
  else if (shm_addr->ionsor == 1)
    printw("TRACKING");
  else
    printw("        ");
  
/* ROW 2 */

  move(ROW1+1,COL1+25);
  preint(outf,shm_addr->INEXT[0],-2,1);
  printw("%s",outfloat);
  move(ROW1+1,COL1+28);
  preint(outf,shm_addr->INEXT[1],-2,1);
  printw("%s",outfloat);
  move(ROW1+1,COL1+31);
  preint(outf,shm_addr->INEXT[2],-2,1);
  printw("%s",outfloat);

  move(ROW1+1,COL1+54);
  preflt(outf,shm_addr->humiwx,-6,2);
  printw("%s",outfloat);

  move(ROW1+1,COL1+66);
  if (posdeg == 1) 
    htemp= raxx*12.0/M_PI;
  else
    htemp= shm_addr->ra50*12.0/M_PI;
  irah=(int)(htemp+.000001);
  iram=(htemp-irah)*60.0;
  ras=(htemp-irah-iram/60.0)*3600.0;
  preint(outf,irah,-2,1);
  printw("%s",outfloat);
  move(ROW1+1,COL1+69);
  preint(outf,iram,-2,1);
  printw("%s",outfloat);
  move(ROW1+1,COL1+72);
  preflt(outf,ras,-4,1);
  printw("%s",outfloat);

/* ROW 3 */

/* MODE */
  move(ROW1+2,COL1+1);
  if (kMrack) {
    switch (shm_addr->imodfm) {
    case 0:
      printw(" a ");
      break;
    case 1:
      printw(" b ");
      break;
    case 2:
      printw(" c ");
      break;
    case 3:
      printw("d  ");
      break;
    default:
      printw("   ");
    }
  }
  else {
    ivalue=shm_addr->vform.mode;
/* hex value for version 290 */
    if (shm_addr->form_version < 656) iversion = 0x7000;
    else iversion = 0x0002;
    if(ivalue >= 0 && ivalue <= NKEY_MODE)
      printw("%-3s",key_mode[ivalue]);
    else
      printw("  ");
  }

/* RATE */
  move(ROW1+2,COL1+5);
  if (kMrack) {
    switch (shm_addr->iratfm) {
    case 0:
      printw("8.000");
      break;
    case 1:
      printw("0.000");
      break;
    case 2:
      printw("0.125");
      break;
    case 3:
      printw("0.250");
      break;
    case 4:
      printw("0.500");
      break;
    case 5:
      printw("1.000");
      break;
    case 6:
      printw("2.000");
      break;
    case 7:
      printw("4.000");
      break;
    default:
      printw("     ");
    }
  }
  else {
    switch (shm_addr->vform.rate) {
    case 0:
      printw("0.250");
      break;
    case 1:
      printw("0.500");
      break;
    case 2:
      printw("1.000");
      break;
    case 3:
      printw("2.000");
      break;
    case 4:
      printw("4.000");
      break;
    case 5:
      printw("8.000");
      break;
    case 6:
      printw("16.00");
      break;
    case 7:
      printw("32.00");
      break;
    default:
      printw("     ");
      break;
    }
  }
  move(ROW1+2,COL1+11);
  switch (shm_addr->ispeed) {
  case 0:
    printw("  0");
    break;
  case 1:
    printw("  3");
    break;
  case 2:
    printw("  8");
    break;
  case 3:
    printw(" 17");
    break;
  case 4:
    printw(" 34");
    break;
  case 5:
    printw(" 68");
    break;
  case 6:
    printw("135");
    break;
  case 7:
    printw("270");
    break;
  case -3:
    printw("%3d",shm_addr->cips/100);
  default:
    printw("  0");
  }

  move(ROW1+2,COL1+16);
  switch (shm_addr->idirtp) {
  case 0:
    printw("REV");
    break;
  case 1:
    printw("FOR");
    break;
  default:
    printw("   ");
  }

  move(ROW1+2,COL1+26);
  printw("%.8s",shm_addr->LSKD);
  move(ROW1+2,COL1+39);
  printw("%.8s",shm_addr->LLOG);
  move(ROW1+2,COL1+53);
  preflt(outf,shm_addr->preswx,-6,1);
  printw("%s",outfloat);
  move(ROW1+2,COL1+65);
  if (posdeg == 1) {
    if (dcxx < 0)
      printw("-");
    else
      printw(" ");
    dtemp=fabs(dcxx)*180.0/M_PI; 
    }
  else {
    if (shm_addr->dec50 < 0)
      printw("-");
    else
      printw(" ");
    dtemp=fabs(shm_addr->dec50)*180.0/M_PI; 
    }
  move(ROW1+2,COL1+66);
  idecd=(int)(dtemp+.00001);
  preint(outf,idecd,-2,1);
  printw("%s",outfloat);
  idecm= (dtemp-idecd)*60.0;
  move(ROW1+2,COL1+69);
  preint(outf,idecm,-2,1);
  printw("%s",outfloat);
  move(ROW1+2,COL1+76);
  if(memcmp(shm_addr->lsorna,"          ",10)==0)  {
    addstr("    ");
  } else {
    preflt(outf,shm_addr->ep1950,-5,0);
    outfloat[4]=0;
    printw("%s",outfloat);
  }

/* ROW 4 */

  move(ROW1+3,COL1+52);
  preflt(outf,shm_addr->cablev,-8,6);
  printw("%s",outfloat);

  if (posdeg==0) {
    cnvrt(1,shm_addr->radat,shm_addr->decdat,&azim,&elev,it,
        shm_addr->alat,shm_addr->wlong);
  } else if (memcmp(shm_addr->lsorna,"azel      ",10)==0 ||
             memcmp(shm_addr->lsorna,"azeluncr  ",10)==0 ) {
        azim = shm_addr->ra50;
        elev = shm_addr->dec50;
  } else if (memcmp(shm_addr->lsorna,"stow      ",10)==0 ||
             memcmp(shm_addr->lsorna,"service   ",10)==0 ||
             memcmp(shm_addr->lsorna,"hold      ",10)==0 ||
             memcmp(shm_addr->lsorna,"disable   ",10)==0 ||
             memcmp(shm_addr->lsorna,"idle      ",10)==0 ||
             memcmp(shm_addr->lsorna,"          ",10)==0)  {
        azim =0.0;
        elev =0.0;
  } else if (memcmp(shm_addr->lsorna,"xy        ",10)==0) {
    cnvrt(4,shm_addr->radat,shm_addr->decdat,&azim,&elev,it,
        shm_addr->alat,shm_addr->wlong);
  }

  move(ROW1+3,COL1+66);
  preflt(outf,(float)azim*RAD2DEG,-5,1);
  printw("%s",outfloat);
  move(ROW1+3,COL1+76);
  preflt(outf,(float)elev*RAD2DEG,-5,1);
  printw("%s",outfloat);

/* ROW 5 */

  move(ROW1+4,COL1+0);
  if (shm_addr->IRDYTP == 0)
    printw("READY   ");
  else if (shm_addr->IRDYTP == 1)
    printw("NOTREADY");
  else
    printw("        ");
  move(ROW1+4,COL1+9);
  if (shm_addr->ICAPTP == 0)
    printw("STOPPED");
  else if (shm_addr->ICAPTP == 1)
    printw("MOVING ");
  else
    printw("       ");
  move(ROW1+4,COL1+17);
  memcpy(ptfeet,shm_addr->LFEET_FS,6);
  printw("%.5s",ptfeet);
  move(ROW1+4,COL1+29);
  preint(outf,(int)(shm_addr->systmp[28]+.5),-3,0);
  printw("%s",outfloat);

  move(ROW1+4,COL1+33);
  preint(outf,(int)(shm_addr->systmp[29]+.5),-3,0);
  printw("%s",outfloat);

  move(ROW1+4,COL1+37);
  preint(outf,(int)(shm_addr->systmp[30]+.5),-3,0);
  printw("%s",outfloat);

  if(!kMrack) {
    move(ROW1+4,COL1+41);
    preint(outf,(int)(shm_addr->systmp[31]+.5),-3,0);
    printw("%s",outfloat);
  }

  it[5]=iyear;
/*
  cnvrt(3,shm_addr->radat,shm_addr->decdat,&xxx,&yyy,it,
        shm_addr->alat,shm_addr->wlong);
*/
  az=azim;
  el=elev;
  cnvrt(10,az,el,&ha,&dc,it,
        shm_addr->alat,shm_addr->wlong);

  outhaa = (float)(ha*12.0/DPI);
  outxxx = (float)(xxx*RAD2DEG);
  outyyy = (float)(yyy*RAD2DEG);
/*
  move(ROW1+4,COL1+46);
  preflt(outf,outxxx,-5,1);
  printw("%s",outfloat);
  move(ROW1+4,COL1+54);
  preflt(outf,outyyy,-5,1);
  printw("%s",outfloat);

  move(ROW1+4,COL1+47);
  preflt(outf,outhaa,-6,2);
  printw("%s",outfloat);
*/

  move(ROW1+4,COL1+74);
  preint(outf,shm_addr->ipashd[0],-3,0);
  printw("%s",outfloat);
  move(ROW1+4,COL1+78);
  preint(outf,shm_addr->ipashd[1],-3,0);
  printw("%s",outfloat);

/* ROW 6 */

  *checkln=0;
  strcat(checkln,"NO CHECK:");

  if (kMrack) {
    for(i=0;i<17;i++) {
      if (shm_addr->ICHK[i]<=0) {
        if (i<=14) {
          strcat(checkln," v");
          if (((i+1)/10) == 0) {
            dig[0]=((i+1)%10) + '0';
            dig[1]= '\0';
          } else {
            dig[0]=((i+1)/10) + '0';
            dig[1]=((i+1)%10) + '0';
            dig[2]= '\0';
          }
          strcat(checkln,dig);
        } else {
          switch (i) {
            case 15:
              strcat(checkln," if");
              break;
            case 16:
              strcat(checkln," fm");
              break;
          }
        }
      }
    }
  } else {                            /* VLBA */
    for (i=0; i<17; i++) {
      if (i<=13) {
        if (shm_addr->check.bbc[i]<=0) {
          strcat(checkln," b");
          if (((i+1)/10) == 0) {
            dig[0]=((i+1)%10) + '0';
            dig[1]= '\0';
          } else {
            dig[0]=((i+1)/10) + '0';
            dig[1]=((i+1)%10) + '0';
            dig[2]= '\0';
          }
          strcat(checkln,dig);
        }
      } else {
        switch (i) {
          case 14:
            if (shm_addr->check.dist[0]<=0)
              strcat(checkln," ia");
            break;
          case 15:
            if (shm_addr->check.dist[1]<=0)
              strcat(checkln," ic");
            break;
          case 16:
            if (shm_addr->check.vform<=0)
              strcat(checkln," fm");
            break;
        }
      }
    }
  }

  if (kMdrive) {
    if (shm_addr->ICHK[17]<=0) {
      strcat(checkln," tp");
    }
  } else {
    if (shm_addr->check.rec<=0)
      strcat(checkln," rc");
  }

  for (i=18; i<21; i++) {
    if (shm_addr->ICHK[i]<=0) {
      switch (i) {
        case 18:
          strcat(checkln," rx");
          break;
        case 19:
          strcat(checkln," hd");
          break;
        case 20:
          if(kMrack) strcat(checkln," i3");
          break;
      }
    }
  }
  for (i=0;i<4;i++)
      if(memcmp(shm_addr->stcnm[i],"  ",2)!=0 && shm_addr->stchk[i]<=0) {
        len=strlen(checkln);
        checkln[len  ]=' ';
        checkln[len+1]=shm_addr->stcnm[i][0];
        checkln[len+2]=shm_addr->stcnm[i][1];
        checkln[len+3]='\0';
      }
  
  move(ROW1+5,0);
  printw("%90s"," ");
  move(ROW1+5,0);
  standout();
  printw("%.90s",checkln);
  standend();

}  /* end mout2 */
