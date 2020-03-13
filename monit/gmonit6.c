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
/* gmonit6

   Open the monit6.ctl control file and read it. Store the contents
   in the cfile structure in ST common.
  
*/

#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <errno.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "mon6.h"

#define MAXLINE   5

int gmonit6(monit6_file, monit6)
     char *monit6_file;
     struct monit6 *monit6;
{
  FILE *file;
  char msg[120];
  int iline;         /* counts non-comment file lines  */
  char c;
  int nc;
  char controller[33];
  char string[33];

  file = fopen(monit6_file,"r");
  if (file == (FILE *)NULL) {
    logit(NULL,errno,"un");
    strcpy(msg,"Open failed for ");
    strcat(msg,monit6_file);
    logite(msg,-1,"mn");
    return(-1);
  }

  iline=0;
  while ((c=getc(file)) != EOF) {
    if (c != '*') {                       /* a comment line        */
      ungetc(c,file); /* put back the character we just got */
      switch (++iline) {
	char string1[5],string2[5];
	int value;
      case 1:
      case 2:
      case 3:
      case 4:
        if (4!= (nc= fscanf(file," %4s %4s %d %d",
			    string1,string2,
			    &monit6->pcal[0][iline-1],
			    &monit6->pcal[1][iline-1]
			    ))) {
	  iline--;
	  if(nc==EOF)
	    goto Ferror;
	  else
	    goto Derror;
	}
	if(strcasecmp("avg",string1)==0)
	  monit6->tsys[0][iline-1]=MAX_RDBE_CH;
	else if(strcasecmp("sum",string1)==0)
	  monit6->tsys[0][iline-1]=MAX_RDBE_CH+1;
	else if(1!=sscanf(string1,"%d", &value) ||
		value<0 || value >MAX_RDBE_CH-1) {
	  snprintf(msg,sizeof(msg),"Must be 'avg', 'sum' or 0-%d.",
		   MAX_RDBE_CH-1);
	  logite(msg,-1,"mn");
	  nc=0;
	  iline--;
	  goto Derror;
	} else
	  monit6->tsys[0][iline-1]=value;

	if(strcasecmp("avg",string2)==0)
	  monit6->tsys[1][iline-1]=MAX_RDBE_CH;
	else if(strcasecmp("sum",string2)==0)
	  monit6->tsys[1][iline-1]=MAX_RDBE_CH+1;
	else if(1!=sscanf(string2,"%d", &value) ||
		value<0 || value >MAX_RDBE_CH-1) {
	  snprintf(msg,sizeof(msg),"Must be 'avg', 'sum' or 0-%d.",
		   MAX_RDBE_CH-1);
	  logite(msg,-1,"mn");
	  nc=1;
	  iline--;
	  goto Derror;
	} else
	  monit6->tsys[1][iline-1]=value;

	if(monit6->pcal[0][iline-1]<0||
		  monit6->pcal[0][iline-1]>1023) {
	  nc=2;
	  iline--;
	  logite("Must be non-negative and less than 1024",-1,"mn");
	  goto Derror;
	} else if(monit6->pcal[1][iline-1]<0||
		  monit6->pcal[1][iline-1]>1023) {
	  nc=3;
	  iline--;
	  logite("Must be non-negative and less than 1024",-1,"mn");
	  goto Derror;
	}
	break;
      case 5:
        if (1!= (nc= fscanf(file," %d",
			    &monit6->dot2pps_ns
			    ))) {
	  iline--;
	  if(nc==EOF)
	    goto Ferror;
	  else
	    goto Derror;
	}
	break;
      default:
	snprintf(msg,sizeof(msg),"More than %d non-comments lines in %s",
		 MAXLINE,monit6_file);
	logite(msg,-1,"mn");
	if(EOF == fclose(file)) {
	  logit(NULL,errno,"un");
	  strcpy(msg,"While closing ");
	  strcat(msg,monit6_file);
	  logite(msg,-1,"mn");
	}
	return(-1);
	break;
      }
    }  /* end of processing this line  */
    while ((c=fgetc(file)) != '\n' && c!= EOF) {
      ;
    }
  } /* end of while reading file to the end */

 Ferror:
  if(ferror(file)) {
    logit(NULL,errno,"un");
    strcpy(msg,"While reading ");
    strcat(msg,monit6_file);
    logite(msg,-1,"mn");
    if(EOF == fclose(file)) {
      logit(NULL,errno,"un");
      strcpy(msg,"While closing ");
      strcat(msg,monit6_file);
      logite(msg,-1,"mn");
    }
    return (-1);
  } else if(iline!=MAXLINE) {
    snprintf(msg,sizeof(msg),"Premature end of file after %d lines in %s.",
	    iline,monit6_file);
    logite(msg,-1,"mn");
    if(EOF == fclose(file)) {
      logit(NULL,errno,"un");
      strcpy(msg,"While closing ");
      strcat(msg,monit6_file);
      logite(msg,-1,"mn");
    }
    return (-1);
  } else {
    if(EOF == fclose(file)) {
      logit(NULL,errno,"un");
      strcpy(msg,"While closing ");
      strcat(msg,monit6_file);
      logite(msg,-1,"mn");
    }
    return 0;
  }
 Derror:
  snprintf(msg,sizeof(msg),
	   "Error in parameter %d on line %d in file %s",
	   nc+1,iline,monit6_file);
  logite(msg,-1,"mn");
  if(EOF == fclose(file)) {
    logit(NULL,errno,"un");
    strcpy(msg,"While closing ");
    strcat(msg,monit6_file);
    logite(msg,-1,"mn");
  }
  return (-1);
}
