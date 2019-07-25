#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include "mparm.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

void preflt(outf,flnum,width,deci)

char *outf;
float flnum;
int width,deci;

{
  void flt2str();

  outf[0]=0;
  flt2str(outf,flnum,width,deci);

}

void preint(outi,inum,width,zorb)

char *outi;
int inum;
int width,zorb;

{
  void int2str();

  *outi=0;
  int2str(outi,inum,width,zorb);

}
