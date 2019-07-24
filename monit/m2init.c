#include <curses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include "mparm.h"
#include "dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

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
}  /* end m2init */
