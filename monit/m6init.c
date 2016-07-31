/* m6init -- RBDE monitor initialization of static characters
 *
 */

#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "mon6.h"

m6init()
{
  mvaddstr(ROW_TITLE0,COL_RDBE-1,   "RDBE");
  mvaddstr(ROW_TITLE0,COL_DOT,      "     DOT");
  mvaddstr(ROW_TITLE0,COL_EPOCH-1,    "EPOCH");
  mvaddstr(ROW_TITLE0,COL_DOT2GPS+4,  "DOT2GPS");
  mvaddstr(ROW_TITLE0,COL_RAW,      "IF  RMS");
  mvaddstr(ROW_TITLE0,COL_TSYS,     "IF0  TSys IF1  TSys");
  mvaddstr(ROW_TITLE0,COL_PCAL,     " Tone    Amp  Phase");

} 
