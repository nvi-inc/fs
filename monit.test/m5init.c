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
  kV4rack,selectm;

m5init()
{

  mvaddstr(ROW1,COL1,"    VSN        Time      GB       %   Check UT");
  mvaddstr(ROW1+1,COL1,"  A");
  mvaddstr(ROW1+2,COL1,"  B");

  refresh();
}  /* end m5init */
