#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <sys/types.h>   /* data type definition header file */
#include <time.h>

#include "../include/params.h"

#include "fmset.h"
#include "fila10g_cfg.h"

struct fila10g_cfg *ask_fila10g_cfg(maindisp,fila10g_cfg)
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
struct fila10g_cfg *fila10g_cfg;
{
  int i,j,inum, ipos;
  char buffer[80];
  struct fila10g_cfg *cfg;
  struct fila10g_cmd *cmd;
  
  nodelay ( maindisp, FALSE );
  echo ();
  
  mvwprintw( maindisp, ROWA, COL0, "Available FiLa10G Configurations:");
  ipos=0;
  cfg=fila10g_cfg;
  while(NULL!=cfg) {
    ipos++;
    sprintf(buffer," %2d. %-16s",ipos,cfg->name);
    mvwprintw( maindisp, ROWA+1+(ipos-1)/3, COL0+((ipos-1)%3)*20, buffer);
    cfg=cfg->next;
  }
  inum=-1;
  while(inum<0 || inum>ipos) {
  mvwprintw( maindisp, ROWA+2+(ipos-1)/3, COL0,
	     "Configuration (number) to be sent, (enter) or 0 for none?     ");
           /* 0123456789012345678901234567890123456789012345678901234567890 */
  inum=0;
  mvwscanw(  maindisp, ROWA+2+(ipos-1)/3, COL0+58, "%d", &inum );
  }
  nodelay ( maindisp, TRUE );
  noecho ();

 for (i=0; i<9;i++)
   for(j=0;j<78-COL0;j++)
     mvwprintw(maindisp,ROWA+i,COL0+j," ");
  
  if(inum==0)
    return NULL;

  ipos=0;  
  cfg=fila10g_cfg;
  while(NULL!=cfg) {
    ipos++;
    if(ipos==inum)
      return cfg;
    cfg=cfg->next;
  }

}
