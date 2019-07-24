#include <curses.h>
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
  int die();
  unsigned rte_sleep();

  setup_ids();

  if (nsem_test(NSEMNAME) != 1) {
    printf("Field System not running\n");
    exit(0);
  }

  initscr();
  signal(SIGINT, die);
  curs_set(0);
  clear();
  refresh();

  m2init();

  while(1) {
    rte_time(it,&iyear);
    move(ROW1,COL1+16);
    printw("%d-%.3d %.2d:%.2d:%.2d",iyear,it[4],it[3],it[2],
            it[1]);
    refresh();
    mout2(it,iyear);
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

m2init()
{

  mvaddstr(ROW1,COL1+34,"UT"); 
  mvaddstr(ROW1,COL1+46,"TEMP");
  mvaddstr(ROW1,COL1+58,"C");

  standout();
  mvaddstr(ROW1+1,COL1+0,"MODE");
  mvaddstr(ROW1+1,COL1+5,"RATE");
  mvaddstr(ROW1+1,COL1+10,"SPEED");
  mvaddstr(ROW1+1,COL1+16,"DIR");
  standend();
  mvaddstr(ROW1+1,COL1+27,":");
  mvaddstr(ROW1+1,COL1+30,":");
  mvaddstr(ROW1+1,COL1+34,"NEXT"); 
  mvaddstr(ROW1+1,COL1+46,"HUMID");
  mvaddstr(ROW1+1,COL1+58,"%  RA");
  mvaddstr(ROW1+1,COL1+67,"h");
  mvaddstr(ROW1+1,COL1+70,"m");
  mvaddstr(ROW1+1,COL1+75,"s");

  mvaddstr(ROW1+2,COL1+20,"SCHED=");
  mvaddstr(ROW1+2,COL1+34,"LOG=");
  mvaddstr(ROW1+2,COL1+46,"PRES");
  mvaddstr(ROW1+2,COL1+57,"mb");
  mvaddstr(ROW1+2,COL1+61,"DEC");
  mvaddstr(ROW1+2,COL1+67,"d");
  mvaddstr(ROW1+2,COL1+70,"m");
  mvaddstr(ROW1+2,COL1+73,"(    )");

  standout();
  mvaddstr(ROW1+3,COL1+0,"VACUUM");
  mvaddstr(ROW1+3,COL1+9,"TAPE");
  mvaddstr(ROW1+3,COL1+18,"FEET");
  mvaddstr(ROW1+3,COL1+23,"IF1");
  mvaddstr(ROW1+3,COL1+28,"TSYS");
  mvaddstr(ROW1+3,COL1+33,"IF2");
  mvaddstr(ROW1+3,COL1+38,"TSYS");
  mvaddstr(ROW1+3,COL1+44,"CABLE");
  standend();
  mvaddstr(ROW1+3,COL1+58,"s");
  mvaddstr(ROW1+3,COL1+61,"AZ");
  mvaddstr(ROW1+3,COL1+71,"EL");

  standout();
/*
Later feature: display x/y or ha depending on axis type
  mvaddstr(ROW1+4,COL1+44,"X");
  mvaddstr(ROW1+4,COL1+52,"Y");
  mvaddstr(ROW1+4,COL1+44,"HA");
*/
  standend();
  mvaddstr(ROW1+4,COL1+61,"HEAD PASS #");
  refresh();
}
  
mout2(it,iyear)

int it[6];
int iyear;
{
  int idum;
  int i, sv, k, icr;
  int irah,iram,idecd,idecm;
  int kMrack, kMdrive;
  int itemp;
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
  char checkarr[81];
  char *checkln; 
  char *ptfeet;
  void preflt();
  void preint();

  ptfeet = &feet[0];
  checkln = &checkarr[0];
  outf = &outfloat[0];

  move(ROW1,COL1+0);
  standout();
  printw("%.8s",shm_addr->lnaant);
  standend();

  if (shm_addr->KHALT!=0) {            /* schedule halted */
    idum=attron(A_BLINK);
    mvaddstr(ROW1,COL1+37,"HALT"); 
    idum=attroff(A_BLINK);
  } else mvaddstr(ROW1,COL1+37,"    "); 

  move(ROW1,COL1+54);
  preflt(outf,shm_addr->tempwx,-4,1);
  printw("%s",outfloat);
  move(ROW1,COL1+61);
  standout();
  printw("%.8s",shm_addr->lsorna);
  standend();
  move(ROW1,COL1+70);
  if (shm_addr->ionsor == 0)
    printw("SLEWING ");
  else if (shm_addr->ionsor == 1)
    printw("TRACKING");
  else
    printw("        ");
  
  move(ROW1+1,COL1+25);
  preint(outf,shm_addr->INEXT[0],-2,1);
  printw("%s",outfloat);
  move(ROW1+1,COL1+28);
  preint(outf,shm_addr->INEXT[1],-2,1);
  printw("%s",outfloat);
  move(ROW1+1,COL1+31);
  preint(outf,shm_addr->INEXT[2],-2,1);
  printw("%s",outfloat);

  move(ROW1+1,COL1+52);
  preflt(outf,shm_addr->humiwx,-6,2);
  printw("%s",outfloat);

  move(ROW1+1,COL1+65);
  htemp= shm_addr->ra50*12.0/M_PI;
  irah=(int)htemp;
  preint(outf,irah,-2,1);
  printw("%s",outfloat);
  move(ROW1+1,COL1+68);
  iram=(htemp-irah)*60.0;
  preint(outf,iram,-2,1);
  printw("%s",outfloat);
  ras=(htemp-irah-iram/60.0)*3600.0;
  move(ROW1+1,COL1+71);
  preflt(outf,ras,-4,1);
  printw("%s",outfloat);

  move(ROW1+2,COL1+1);
  switch (shm_addr->imodfm) {
  case 0:
    printw(" a");
    break;
  case 1:
    printw(" b");
    break;
  case 2:
    printw(" c");
    break;
  case 3:
    printw(" d");
    break;
  default:
    printw("  ");
  }

  move(ROW1+2,COL1+5);
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
    printw("8.000");
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
    printw("  7");
    break;
  case 3:
    printw(" 15");
    break;
  case 4:
    printw(" 30");
    break;
  case 5:
    printw(" 60");
    break;
  case 6:
    printw("120");
    break;
  case 7:
    printw("240");
    break;
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
  move(ROW1+2,COL1+38);
  printw("%.8s",shm_addr->LLOG);
  move(ROW1+2,COL1+51);
  preflt(outf,shm_addr->preswx,-6,1);
  printw("%s",outfloat);
  move(ROW1+2,COL1+64);
  if (shm_addr->dec50 < 0)
    printw("-");
  else
    printw(" ");
  dtemp=fabs(shm_addr->dec50)*180.0/M_PI; 
  move(ROW1+2,COL1+65);
  idecd=(int)dtemp;
  preint(outf,idecd,-2,1);
  printw("%s",outfloat);
  idecm= (dtemp-idecd)*60.0;
  move(ROW1+2,COL1+68);
  preint(outf,idecm,-2,1);
  printw("%s",outfloat);
  move(ROW1+2,COL1+74);
  preflt(outf,shm_addr->ep1950,-5,0);
  outfloat[4]=NULL;
  printw("%s",outfloat);

  move(ROW1+3,COL1+50);
  preflt(outf,shm_addr->cablev,-8,6);
  printw("%s",outfloat);

/*azel(it,shm_addr->alat,shm_addr->wlong,shm_addr->radat,
       shm_addr->decdat,&azim,&elev);
*/
  cnvrt(1,shm_addr->radat,shm_addr->decdat,&azim,&elev,it,
        shm_addr->alat,shm_addr->wlong);

  move(ROW1+3,COL1+64);
  preflt(outf,(float)azim*RAD2DEG,-5,1);
  printw("%s",outfloat);
  move(ROW1+3,COL1+74);
  preflt(outf,(float)elev*RAD2DEG,-5,1);
  printw("%s",outfloat);

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
  move(ROW1+4,COL1+23);
  if (shm_addr->inp1if == 0)
    printw("NOR");
  else if (shm_addr->inp1if == 1)
    printw("ALT");
  else
    printw("   ");
  move(ROW1+4,COL1+27);
  preflt(outf,shm_addr->systmp[28],-5,1);
  printw("%s",outfloat);
  move(ROW1+4,COL1+33);
  if (shm_addr->inp2if == 0)
    printw("NOR");
  else if (shm_addr->inp2if == 1)
    printw("ALT");
  else
    printw("   ");
  move(ROW1+4,COL1+37);
  preflt(outf,shm_addr->systmp[29],-5,1);
  printw("%s",outfloat);

  it[5]=iyear;
/*
  cnvrt(3,shm_addr->radat,shm_addr->decdat,&xxx,&yyy,it,
        shm_addr->alat,shm_addr->wlong);
*/
  az=azim;
  el=elev;
  cnvrt(10,az,el,&ha,&dc,it,
        shm_addr->alat,shm_addr->wlong);

/*move(10,10);
printw("xxx =%9.6f yyy=%9.6f\n",xxx*RAD2DEG,yyy*RAD2DEG);
*/
  outhaa = (float)(ha*12.0/DPI);
  outxxx = (float)(xxx*RAD2DEG);
  outyyy = (float)(yyy*RAD2DEG);
/*move(11,10);
printw("xxx =%9.6f yyy=%9.6f\n",outxxx,outyyy);
*/
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

  move(ROW1+4,COL1+73);
  preint(outf,shm_addr->ipashd[0],-2,1);
  printw("%s",outfloat);
  move(ROW1+4,COL1+77);
  preint(outf,shm_addr->ipashd[1],-2,1);
  printw("%s",outfloat);

  *checkln=NULL;
  strcat(checkln,"NO CHECK:");

  kMrack = 0;
  kMdrive = 0;
  itemp=shm_addr->equip.rack;
  if ((itemp & 0x01)!=0) kMrack=1;
  itemp=shm_addr->equip.drive;
  if ((itemp & 0x01)!=0) kMdrive=1;

  for(i=0;i<20;i++) {
    if (i<17) {
      if (kMrack) {   /* MK3 */
        if (shm_addr->ICHK[i]<=0) {
          icr = i-14;
          if (icr<=0) {
            strcat(checkln," v");
            if (((i+1)/10) == 0) {
              dig[0]=((i+1)%10) + '0';
              dig[1]= '\0';
            }
            else {
              dig[0]=((i+1)/10) + '0';
              dig[1]=((i+1)%10) + '0';
              dig[2]= '\0';
            }
            strcat(checkln,dig);
          }
          else
          switch (icr) {
          case 1:
            strcat(checkln," if");
            break;
          case 2:
            strcat(checkln," fm");
            break;
          }
        }
      }
      else if (!kMrack) {   /* VLBA */
        icr = i-14;
        if (icr<=0) {
          if (shm_addr->check.bbc[icr]<=0) {
            strcat(checkln," b");
            if (((i+1)/10) == 0) {
              dig[0]=((i+1)%10) + '0';
              dig[1]= '\0';
            }
            else {
              dig[0]=((i+1)/10) + '0';
              dig[1]=((i+1)%10) + '0';
              dig[2]= '\0';
            }
            strcat(checkln,dig);
          }
        }
        else {
          switch (icr) {
            case 1:
              if (shm_addr->check.dist[icr]<=0)
                strcat(checkln," ia");
              break;
            case 2:
              if (shm_addr->check.dist[icr]<=0)
                strcat(checkln," ic");
              break;
          }
        }
      }
    }
    else if (i==17) {
      if (kMdrive) {
        if (shm_addr->ICHK[i]<=0)
          strcat(checkln," tp");
      }
      else if (!kMrack) {
        if (shm_addr->check.vform<=0)
          strcat(checkln," fm");
      }
    }
    else if (i==18) {
      if (shm_addr->ICHK[i]<=0)
        strcat(checkln," rx");
      if (!kMdrive) {
        if (shm_addr->check.rec<=0)
          strcat(checkln," rc");
      }
    }
    else if (i==19) {
      if (kMdrive) {
        if (shm_addr->ICHK[i]<=0)
          strcat(checkln," hd");
      }
    }
  }
  move(ROW1+5,0);
  printw("%80s"," ");
  standout();
  move(ROW1+5,0);
  printw("%s",checkln);
  standend();
  move(ROW1+6,COL1+0);

  refresh();
}
