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
#include <ctype.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

int dbbc_version_check(char *inbuf, char *output)
{
  int i, ierr;

  ierr=0;

  /*                     12345678
    in buff starts with "version/", but may have any extar space after '/' */

  if(inbuf[8] == ' ') {
    int i,len=strlen(inbuf);
    for (i=9;i<=len;i++) { /* <= to move trailing \0 */
      inbuf[i-1]=inbuf[i];
    }
  }
  
  if(DBBC_DDC == shm_addr->equip.rack_type ||
     DBBC_DDC_FILA10G == shm_addr->equip.rack_type) {
    int iversion=0;
    int j;
    /*                   123456789012 */
    if (strncmp(inbuf+8,"July 14 2011",12)==0||
	strncmp(inbuf+8,"Feb 21 2011",11)==0)
      iversion=100;
    /*                       1234567890123 */
    else if(strncmp(inbuf+8,"March 08 2012",13)==0)
      iversion =101;
    /*                       12345678901234567890123 */
    else if(strncmp(inbuf+8,"102 - September 07 2012",23)==0)
      iversion =102;
    /*                       123456789012 */
    else if(strncmp(inbuf+8,"July 04 2012",12)==0)
      iversion =-102;
    /*                       12345678901234567890123 */
    else if(strncmp(inbuf+8,"DDC,103,October 04 2012",23)==0)
      iversion =103;
    /*                       123456789012345678901 */
    else if(strncmp(inbuf+8,"DDC,104,March 19 2013",21)==0)
      iversion = -104;
    /*                       1234567890123456789012 */
    else if(strncmp(inbuf+8,"DDC,104,June 20 2013",20)==0 ||
	    strncmp(inbuf+8,"DDC,104,August 01 2013",22)==0)
      iversion =104;
    else if(strncmp(inbuf+8 ,"DDC,",4)==0) {
      char test_buf[sizeof(shm_addr->dbbcddcvs)];
      char *comma;
      
      strncpy(test_buf,inbuf+12,sizeof(test_buf));
      test_buf[sizeof(test_buf)-1]=0;
      
      comma=strchr(test_buf,',');
      if(NULL!=comma)
	*comma=0;
      
      for(j=0;j<strlen(test_buf);j++)
	test_buf[j]=tolower(test_buf[j]);
      
      if(strncmp(test_buf,shm_addr->dbbcddcvs,shm_addr->dbbcddcvc)==0 &&
	 strlen(test_buf)==shm_addr->dbbcddcvc)
	iversion=shm_addr->dbbcddcv;
    } else if(strncmp(inbuf+8 ,"PFB,",4)==0) {
      ierr = -11;
    }
    if(iversion!=shm_addr->dbbcddcv) {
      switch(iversion) {
      case 100:
	ierr = -3;
	break;
      case 101:
	ierr = -4;
	break;
      case 102:
	ierr = -5;
	break;
      case 103:
	ierr = -7;
	break;
      case 104:
	ierr = -8;
	break;
      case -102:
	ierr = -9;
	break;
      case -104:
	ierr = -10;
	break;
      default:
	if(-11!=ierr)
	  ierr = -6;
	break;
      }
      if(NULL !=output && (ierr==-6 || ierr == -11)) {	   
	if(output[strlen(output)-1]!='/')
	  strcat(output,",");
	strcat(output,inbuf);
      }
    }
  } else if(DBBC_PFB == shm_addr->equip.rack_type ||
	    DBBC_PFB_FILA10G == shm_addr->equip.rack_type) {
    int iversion=0;
    int j;
    
    if(strncmp(inbuf+8 ,"PFB,",4)==0) {
      char test_buf[sizeof(shm_addr->dbbcpfbvs)];
      char *comma;
      
      strncpy(test_buf,inbuf+12,sizeof(test_buf));
      test_buf[sizeof(test_buf)-1]=0;
      
      comma=strchr(test_buf,',');
      if(NULL!=comma)
	*comma=0;
      
      for(j=0;j<strlen(test_buf);j++)
	test_buf[j]=tolower(test_buf[j]);
      
      if(strncmp(test_buf,shm_addr->dbbcpfbvs,shm_addr->dbbcpfbvc)==0 &&
	 strlen(test_buf)==shm_addr->dbbcpfbvc)
	iversion=shm_addr->dbbcpfbv;
    } else if(strncmp(inbuf+8 ,"DDC,",4)==0) {
      ierr = -12;
    }
    if(iversion!=shm_addr->dbbcpfbv) {
      if (-12 != ierr)
	ierr = -6;
    }
    if(NULL!=output && (ierr==-6 || ierr == -12)) {	   
      if(output[strlen(output)-1]!='/')
	strcat(output,",");
      strcat(output,inbuf);
    }
  } else {
    ierr=-13;
  }

  return ierr;
}
