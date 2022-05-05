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
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <syslog.h>

#define MAX_BUF 120
logtacd(
      char fsloc_str[],
      char tacd_str[],
      char sn[],
      char logfile[])
{
  /*            /usr2/log/tacd99001gg.log   */
  int i,k,j;
  char file[]= "                                       ";
  char new[sizeof(file)];
  char new2[sizeof(file)];
  int error,total,ncopy;
  struct tm *ptr;
  time_t t;
  char buffer[MAX_BUF];
  char ch;
  static FILE *fildes=  NULL;
  long offset;

  t=time(NULL);
  if(((time_t) -1) == t) {
    err_report("Error getting time in logtacd",NULL,1,0);
    return;
  }

  /* Setup new logfile. */
  ptr=gmtime(&t);
  i=strlen(logfile);
  strcpy(new,logfile);
  k=strlen(new);
  strftime(new+strlen(new),sizeof(new),"/tacd%y%j",ptr);
  if(-1==snprintf(new+strlen(new),sizeof(new)-strlen(new),
		  "%c%c.log",sn[0],sn[1])) {
    err_report("Error formatting entry for log in logtacd",new,1,0);
    return;
  }
  if(strcmp(new,file)!=0) {
    if(fildes !=  NULL) {
      if(EOF == fclose(fildes)) {
	err_report("Closing old log in logtacd",file,1,0);
	return;
      }
    }

    fildes=(fopen(new,"a+"));
    if(fildes ==  NULL) {
      err_report("Opening new log in logtacd",new,1,0);
      return;
    }
    if(0!=chmod(new,0666)) {
      err_report("Setting permissions in logtacd",new,1,0);
      return;
    }

    strncpy(file,new,sizeof(file));
    offset=ftell(fildes);
    if(offset==-1) {
      err_report("Opening checking log position in logtacd",new,1,0);
      return;
    }
    if(offset!=0){
      if(EOF==fseek(fildes, -1,SEEK_END)) {
	err_report("Error positioning log in logtacd",new,1,0);
	return;
      }
      if(EOF==fread(&ch,1,1,fildes)) {
	err_report("Error reading log in logtacd",new,1,0);
	return;
      }
      if(ch!='\n') {
	ch='\n';
	if(1!=fwrite(&ch,1,1,fildes)) {
	  err_report("Error adding newline to log in logtacd",new,1,0);
	  return;
	}
      }
    }
  }
  if(ftell(fildes)==0) {
    if(strlen(fsloc_str)+1!=fprintf(fildes,"%s\n",fsloc_str)) {
      err_report("Error writing entry to log in logtacd",new,1,0);
      return;
    }
  }

  if(-1==snprintf(buffer,sizeof(buffer)-strlen(buffer),"%s",tacd_str)){
    err_report("Error formatting entry for log in logtacd",new,1,0);
    return;
  }
      
  if(strlen(buffer)+1!=fprintf(fildes,"%s\n",buffer)) {
    err_report("Error writing entry to log in logtacd",new,1,0);
    return;
  }

  if(EOF == fflush(fildes)) {
    err_report("Error flushing log stream in logtacd",new,1,0);
    return;
  }

}    
