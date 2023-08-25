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
#include "mparm.h"
#include "dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

extern int kMrack, kMdrive[2], kS2drive[2],kVrack,kVdrive[2],kK4drive[2],
  kV4rack,kDrack, selectm;

m2init()
{

  mvaddstr(ROW1,COL1+35,"UT"); 
  mvaddstr(ROW1,COL1+48,"TEMP");
  mvaddstr(ROW1,COL1+60,"C");

  mvaddstr(ROW1+1,COL1+10,"     ");
  mvaddstr(ROW1+1,COL1+16,"   ");
  mvaddstr(ROW1+1,COL1+5,"     ");
  mvaddstr(ROW1+1,COL1+13,"     ");
  mvaddstr(ROW1+1,COL1+5,"    ");

  standout();
  mvaddstr(ROW1+1,COL1+0,"MODE");
  mvaddstr(ROW1+1,COL1+5,"RATE");
    
  if(kMdrive[selectm] || kVdrive[selectm]) {
    mvaddstr(ROW1+1,COL1+10,"SPEED");
    mvaddstr(ROW1+1,COL1+16,"DIR");
  } else if(kS2drive[selectm]){
    mvaddstr(ROW1+1,COL1+5,"GROUP");
    mvaddstr(ROW1+1,COL1+13,"SPEED");
  } else if(kK4drive[selectm]) {
    mvaddstr(ROW1+1,COL1+5,"RATE");
  } 
    
  standend();
  mvaddstr(ROW1+1,COL1+27,":");
  mvaddstr(ROW1+1,COL1+30,":");
  mvaddstr(ROW1+1,COL1+35,"NEXT"); 
  mvaddstr(ROW1+1,COL1+48,"HUMID");
  mvaddstr(ROW1+1,COL1+60,"% RA");
  mvaddstr(ROW1+1,COL1+68,"h");
  mvaddstr(ROW1+1,COL1+71,"m");
  mvaddstr(ROW1+1,COL1+76,"s");

  mvaddstr(ROW1+2,COL1+20,"SCHED=");
  mvaddstr(ROW1+2,COL1+35,"LOG=");
  mvaddstr(ROW1+2,COL1+48,"PRES");
  mvaddstr(ROW1+2,COL1+59,"mb");
  mvaddstr(ROW1+2,COL1+62,"DEC");
  mvaddstr(ROW1+2,COL1+68,"d");
  mvaddstr(ROW1+2,COL1+71,"m");
  mvaddstr(ROW1+2,COL1+75,"(    )");

  mvaddstr(ROW1+3,COL1+0,"     ");
  mvaddstr(ROW1+3,COL1+11,"   ");
  mvaddstr(ROW1+3,COL1+19,"   ");
  mvaddstr(ROW1+3,COL1+0,"      ");
  mvaddstr(ROW1+3,COL1+9,"    ");
  mvaddstr(ROW1+3,COL1+15," ");
  mvaddstr(ROW1+3,COL1+18,"    ");
  mvaddstr(ROW1+3,COL1+0,"        ");
  standout();
  if(kS2drive[selectm]) {
    mvaddstr(ROW1+3,COL1+0,"STATE");
    mvaddstr(ROW1+3,COL1+11,"POS");
    mvaddstr(ROW1+3,COL1+19,"VAR");
  } else if(kMdrive[selectm] || kVdrive[selectm]) {
    mvaddstr(ROW1+3,COL1+0,"VACUUM");
    mvaddstr(ROW1+3,COL1+9,"TAPE");
    standend();
    if(selectm==0)
      mvaddstr(ROW1+3,COL1+15,"1");
    else
      mvaddstr(ROW1+3,COL1+15,"2");
    standout();
    mvaddstr(ROW1+3,COL1+18,"FEET");
  } else if(kK4drive[selectm]) {
    mvaddstr(ROW1+3,COL1+0,"SEQUENCE");
  } 
  if (kMrack) {
    mvaddstr(ROW1+3,COL1+23,"TSYS:");
    mvaddstr(ROW1+3,COL1+29,"IF1");
    mvaddstr(ROW1+3,COL1+33,"IF2");
    mvaddstr(ROW1+3,COL1+37,"IF3");
/*  mvaddstr(ROW1+3,COL1+41,"IF4"); */
  } else if( kVrack||kV4rack) {
    mvaddstr(ROW1+3,COL1+23,"TSYS:");
    mvaddstr(ROW1+3,COL1+29,"IFA");
    mvaddstr(ROW1+3,COL1+33,"IFB");
    mvaddstr(ROW1+3,COL1+37,"IFC");
    mvaddstr(ROW1+3,COL1+41,"IFD");
  } else if (kDrack) {
    mvaddstr(ROW1+3,COL1+23,"TSYS:");
    mvaddstr(ROW1+3,COL1+29,"IFA");
  
    if(shm_addr->dbbc_cond_mods > 1) 
      mvaddstr(ROW1+3,COL1+33,"IFB");
    if(shm_addr->dbbc_cond_mods > 2) 
      mvaddstr(ROW1+3,COL1+37,"IFC");
    if(shm_addr->dbbc_cond_mods > 3) 
      mvaddstr(ROW1+3,COL1+41,"IFD");
  }
  mvaddstr(ROW1+3,COL1+46,"CABLE");
  standend();
  mvaddstr(ROW1+3,COL1+60,"s");
  mvaddstr(ROW1+3,COL1+62,"AZ");
  mvaddstr(ROW1+3,COL1+73,"EL");

  standout();
/*
Later feature: display x/y or ha depending on axis type
  mvaddstr(ROW1+4,COL1+44,"X");
  mvaddstr(ROW1+4,COL1+52,"Y");
  mvaddstr(ROW1+4,COL1+44,"HA");
*/
  standend();
  mvaddstr(ROW1+4,COL1+62,"           ");
  if(kMdrive[selectm]||kVdrive[selectm])
    mvaddstr(ROW1+4,COL1+62,"HEAD PASS #");
  refresh();
}  /* end m2init */
