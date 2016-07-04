/* m6init -- RBDE monitor initialization of static characters
 *
 */

#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include "mon6.h"

m6init()
{
  mvaddstr(ROW_TITLE0,COL_RDBE-1,   "RDBE");
  mvaddstr(ROW_TITLE0,COL_DOT,      "     DOT");
  mvaddstr(ROW_TITLE0,COL_EPOCH-1,    "EPOCH");
  mvaddstr(ROW_TITLE0,COL_DOT2GPS+4,  "DOT2GPS");
  mvaddstr(ROW_TITLE0,COL_RAW,      "IF  RMS");
  mvaddstr(ROW_TITLE0,COL_TSYS,     "TSys0  TSys1");
  mvaddstr(ROW_TITLE0,COL_PCAL,     " Tone    Amp  Phase");

} 
