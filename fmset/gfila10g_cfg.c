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
/* gfila10g_cfg

   Open the fila10g_cg.ctl control file and read it. Store the contents
   in a linked list. Many presisting malloc() creaetd memory blocks are pointed
   to by the list and still exist on return. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "fila10g_cfg.h"

#define NAME_LEN_MAX 16
#define CMD_LEN_MAX 256
#define CONFIG_MAX 21

int gfila10g_cfg(fila10g_cfg_file, next_cfg)
     char *fila10g_cfg_file;
     struct fila10g_cfg **next_cfg;
{
  FILE *file;
  char msg[512];
  int iline;         /* counts file lines  */
  int icount;        /*counts configs */
  char c;
  char *bptr,*ptr;
  int bsize,iret;
  struct fila10g_cmd **next_cmd=NULL;
  struct fila10g_cfg *first_cfg;

  file = fopen(fila10g_cfg_file,"r");
  if (file == (FILE *)NULL) {
    logit(NULL,errno,"un");
    strcpy(msg,"Open failed for ");
    strcat(msg,fila10g_cfg_file);
    logite(msg,-1,"fm");
    return(-1);
  }

  iline=0;
  icount=0;
  while ((c=fgetc(file)) != EOF) {
    iline++;
    if (c == '*') {                       /* a comment line */
      while ((c=fgetc(file)) != EOF && c!='\n') 
	;
      if(ferror(file)) {
	logit(NULL,errno,"un");
	sprintf(msg,"Reading comment at line %d",iline);
	goto Error;
      } else
	continue;
    } else {
      iret=ungetc(c,file); /* put back the character we just got */
      if(-1==iret)
	if(ferror(file)) {
	  logit(NULL,errno,"un");
	  sprintf(msg,"Read (ungetc) failed at line %d",iline);
	  goto Error;
	} else
	  return 0;

      bptr=NULL;
      iret=getline(&bptr,&bsize,file);
      if(-1==iret)
	if(ferror(file)) {
	  logit(NULL,errno,"un");
	  sprintf(msg,"Read (getline) failed at line %d",iline);
	  goto Error;
	} else
	  return 0;

      ptr=bptr;
      while(isspace(*ptr)) {
	ptr++;
      }
      if(0==*ptr || isspace(*bptr)) {
	sprintf(msg,"First character on line is white space or there is a blank line at line %d",iline);
	goto Error;
      }

      if('$'==*ptr) {
	ptr=strtok(bptr," \n");
	if(!strcasecmp(ptr,"$config")) {
	  ptr=strtok(NULL," \n");
	  if(NULL==ptr) {
	    sprintf(msg,"Missing $config name at line %d",iline);
	    goto Error;
	  } else if(strlen(ptr) > NAME_LEN_MAX) {
	    sprintf(msg,"$config name greater than %d characters at line %d",
		    NAME_LEN_MAX,iline);
	    goto Error;
	  } else {
	    *next_cfg=malloc(sizeof(struct fila10g_cfg));
	    if(NULL==*next_cfg) {
	      sprintf(msg,"Alocating memory for config at line %d",iline);
	      goto Error;
	    }
	    if(1==++icount) {
	      first_cfg=*next_cfg;
	    } else if(icount>CONFIG_MAX){
	      sprintf(msg,"More than %d $config names at line %d",
		    CONFIG_MAX,iline);
	    goto Error;
	    } else {
	      struct fila10g_cfg *cfg;

	      cfg=first_cfg;
	      while(NULL!=cfg->name) {
		if(!strcmp(cfg->name,ptr)) {
		  sprintf(msg,"Duplicate $config name at line %d",iline);
		  goto Error;
		}
		cfg=cfg->next;
	      }
	    }
	    (*next_cfg)->name=ptr;
	    (*next_cfg)->cmd=NULL;
	    (*next_cfg)->next=NULL;
	    next_cmd=&(*next_cfg)->cmd;
	    next_cfg=&(*next_cfg)->next;
	  }
	} else {
	  sprintf(msg,"Unknown '$'-block at line %d",iline);
	  goto Error;
	}
      } else if(NULL==next_cmd) {
	sprintf(msg,"A $config line is not the first non-comment line at line %d",iline);
	goto Error;
      } else {
	ptr=bptr+strlen(bptr)-1;
	while(isspace(*ptr))
	  *ptr--=0;
	*next_cmd=malloc(sizeof(struct fila10g_cmd));
	if(NULL==*next_cmd) {
	  sprintf(msg,"Alocating memory for command at line %d",iline);
	  goto Error;
	} else if(strlen(bptr) > CMD_LEN_MAX) {
	  sprintf(msg,"command greater than %d characters at line %d",
		  CMD_LEN_MAX,iline);
	  goto Error;
	} else {
	  (*next_cmd)->cmd=bptr;
	  (*next_cmd)->next=NULL;
	  next_cmd=&(*next_cmd)->next;
	  
	}   
      }
    }
  } /* end of while reading file to the end */

  if(ferror(file)) {
    logit(NULL,errno,"un");
    sprintf(msg,"Read (fgetc) failed at line %d",iline);
    goto Error;
  } else
    return 0;

 Error:
  strcat(msg," in ");
  strcat(msg,fila10g_cfg_file);
  logite(msg,-11,"fv");
  return(-1);

}
