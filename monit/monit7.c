/*
 * Copyright (c) 2020-2023 NVI, Inc.
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
/* monit7 -- DBBC3 monitor program
 */
#include <ncurses.h>
#include <stdlib.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "mon7.h"

struct fscom *fs;

#define DWELL_SECONDS 2

void resize()
{
  clear();
  refresh();
}
main(int argc, char *argv[])
{
    int it[6], iyear, isleep;
    void m7init();
    void m7out( int next, int iping);
    void die();
    void resize();
    unsigned rte_sleep();
    char ch;
    char numbers[]  = "123456789";
    char letters[]  = "abcdefgh";
    char lettersu[] = "ABCDEFGH";
    int reverse;

    if(argc == 2) {
        if(strcmp(argv[1],"-rv")) {
            printf("Bad argument '%s', only '-rv' allowed\nPausing 10 seconds then monit7 will terminate.\n",argv[1]);
            sleep(10);
            exit(-1);
        } else
            reverse = 1;
    } else if (argc >2) {
        printf("Too many arguments '%d', only '1' allowed\nPusing 10 seconds then monit7 will terminate.\n",argc-1);
        sleep(10);
        exit(-1);
    } else
        reverse = 0;

    setup_ids();
    fs = shm_addr;

    /*  First check to see if the field system is running */

    if (nsem_test("fs   ") != 1) {
        printf("Field System not running, pausing 10 seconds then monit7 will terminate.\n");
        sleep(10);
        exit(-1);
    } else if (shm_addr->equip.rack != DBBC3 ) {
        printf("Non-DBBC3 rack, pausing 10 seconds then monit7 will terminate.\n");
        sleep(10);
        exit(-1);
    }

    initscr();
    signal(SIGINT, die);
    signal(SIGWINCH, resize);
    noecho ();
    nodelay(stdscr, TRUE);

    curs_set(0);
    clear();
    refresh();

    if(has_colors()) {
      start_color();
      use_default_colors();
      init_pair(DEFAULT,-1,-1);
      init_pair(GREEN,COLOR_BLACK,COLOR_GREEN);
      init_pair(YELLOW,COLOR_BLACK,COLOR_YELLOW);
      init_pair(RED,COLOR_WHITE,COLOR_RED);
      init_pair(BLUE,COLOR_WHITE,COLOR_BLUE);
      init_pair(CYAN,COLOR_BLACK,COLOR_CYAN);
      init_pair(GREENI,COLOR_WHITE,COLOR_GREEN);
      init_pair(YELLOWI,COLOR_WHITE,COLOR_YELLOW);
      init_pair(REDI,COLOR_BLACK,COLOR_RED);
      init_pair(BLUEI,COLOR_BLACK,COLOR_BLUE);
      init_pair(CYANI,COLOR_WHITE,COLOR_CYAN);
    }
    int next=-1;
    int count=-1;
    int dwell=DWELL_SECONDS;
    int ifc=0;
    int krf=1;
    int all=0;
    int is_escape=0;
    int is_lb=0;
    int is_inter=0;
    for(;;) {
        rte_time(it,&iyear);
        isleep=100-it[0];
        isleep=isleep>100?100:isleep;
        isleep=isleep<1?100:isleep;
        rte_sleep((unsigned) isleep);

        if (nsem_test("fs   ") != 1) {
            printf("Field System terminated\n");
            die();
            exit(0);
        }
        while(ERR!=(ch=getch())) {  /* handle inputs */

            if(is_escape) { /* filter escape sequences */
              if (!is_lb) {
                 if('[' != ch) { /* not CSI */
                   is_inter=is_lb=is_escape=0;
                   goto next;
                 } else {  /* CSI */
                   is_lb=1;
                   continue;
                 }
              } else if(0x30 <= ch && ch <= 0x3F) { /* CSI parameter */
                if(is_inter) { /* not after intermediate */
                   is_inter=is_lb=is_escape=0;
                   goto next;
                } else {
                   continue;
                }
              } else if(0x20 <= ch && ch <= 0x2F) { /* CSI intermediate */
                is_inter=1;
                continue;
              } else if(0x40 <= ch && ch <= 0x7E) { /* CSI final */
                is_inter=is_lb=is_escape=0;
                continue;
              } else {
                continue;
              }
            }

        next:
            if ('\e' ==ch) {
              is_escape=1;
              continue;
            }

            char *num=strchr(numbers,ch);
            if(NULL != num) {
                dwell=num-numbers+1;
                continue;
            }
            char *ptr=strchr(letters,ch);
            int ifc_before=ifc;
            ifc = -1;
            if (NULL != ptr) {
                ifc=ptr-letters+1;
                count=-1;
            } else if (NULL != (ptr=strchr(lettersu,ch))) {
                ifc=ptr-lettersu+1;
                count=-1;
            } else if ('n' == ch) {
                ifc=1+(next+1)%fs->dbbc3_ddc_ifs;
                count=-1;
            } else if ('p' == ch) {
                ifc=1+(next+fs->dbbc3_ddc_ifs-1)%fs->dbbc3_ddc_ifs;
                count=-1;
            } else if ('l' == ch) {
                all=1-all;
                count=-1;
                ifc=ifc_before;
            } else if ('i' == ch) {
                krf=1-krf;
                count=-1;
                ifc=ifc_before;
            } else if ('0' == ch) {
                krf=1;
                count=-1;
                all=0;
                ifc=0;
                dwell=DWELL_SECONDS;
            } else if ( '?' == ch || '/' == ch) {
                clear();
                move(0,0);
                printw("Single key inputs:");
                move(1,0);
                printw("a-h - that IF");
                move(2,0);
                printw("n/p - next/previous IF");
                move(3,0);
                printw("1-9 - dwell seconds");
                move(4,0);
                printw("i - toggle RF/IF");
                move(5,0);
                printw("l - toggle all/rec(def)");
                move(6,0);
                printw("0 reset all to defaults");
                move(7,0);
                printw("? or / - help");
                move(8,0);
                printw("Control-C to exit");
                move(9,0);
                printw("Any other: resume cycle");
                move(11,0);
                printw("   Use any key now to");
                move(12,0);
                printw("       leave help");
                while(ERR==getch())
                    ;
                clear();
                ifc=ifc_before;
            }
            if(-1==ifc || ifc>fs->dbbc3_ddc_ifs)
                ifc=0;
        }
        /* update display */
        int iping=shm_addr->dbbc3_tsys_data.iping;
        int undef;
        int record;
        int i;
        /* find next IF to display */
        if (0==ifc) {
            count=++count%dwell;
            if (0==count) {
// logic states
//
// not recording a/r  action           show        states
// ------------- ---  -----            ---- -------------------
// all undef          cycle all        All   undef !record !all
// all undef     all  cycle all        All   undef !record  all
// some defs          cylce defs       Def  !undef !record !all
// some defs     all  cycle all        All  !undef !record  all
//
// recording     a/r  action           show        states
// ------------- ---  -----            ---- -------------------
// all undef          cycle recording  Rec   undef  record !all
// all undef     all  cycle all        All   undef  record  all
// some defs          cycle recording  Rec  !undef  record !all
// some defs     all  cycle all        All  !undef  record  all
//
                record=FALSE;
                for(i=0;i<fs->dbbc3_ddc_ifs;i++)
                    record=record ||
                                (shm_addr->dbbc3_core3h_modex[i].mask1.state.known &&
                                 shm_addr->dbbc3_core3h_modex[i].mask1.mask1) ||
                                (shm_addr->dbbc3_core3h_modex[i].mask2.state.known &&
                                 shm_addr->dbbc3_core3h_modex[i].mask2.mask2);
                undef=TRUE;
                for(i=0;i<fs->dbbc3_ddc_ifs;i++)
                    undef=undef &&
                        fs->dbbc3_tsys_data.data[iping].ifc[i].lo<0;

                if(!record) {
                    if(undef) {
                        next=++next%fs->dbbc3_ddc_ifs;
                    } else {
                        for (i=0;i<fs->dbbc3_ddc_ifs;i++) {
                            next=++next%fs->dbbc3_ddc_ifs;
                            if(all || fs->dbbc3_tsys_data.data[iping].ifc[next].lo>=0)
                                break;
                        }
                    }
                } else {
                    for (i=0;i<fs->dbbc3_ddc_ifs;i++) {
                        next=++next%fs->dbbc3_ddc_ifs;
                        if(all || (shm_addr->dbbc3_core3h_modex[next].mask1.state.known &&
                                 shm_addr->dbbc3_core3h_modex[next].mask1.mask1) ||
                                (shm_addr->dbbc3_core3h_modex[next].mask2.state.known &&
                                 shm_addr->dbbc3_core3h_modex[next].mask2.mask2)) {
                            break;
                        }
                    }
                }
            }
        } else
            next=ifc-1;
//        if(idebug++>0) {
//            printf(" iping %d\n",iping);
//            die();
//            exit(0);
//        }
        mout7(next,&shm_addr->dbbc3_tsys_data.data[iping],krf,all,!undef,record,reverse);
        move(ROW_HOLD,COL_HOLD);  /* place cursor at consistent location */
        standend();
        printw(" ");

        refresh();
    }

}  /* end main of monit6 */
