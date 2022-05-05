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
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

play_wav(iwhich)
int iwhich;
{
  char command[512];
  size_t isize;
  char *wav;
  static char *wav1,*wav2;
  static int first=1;

  if(first) {
    wav1=getenv("FS_ERROR_WAV");
    wav2=getenv("FS_WAKEUP_WAV");
    first=0;
  }

  if(iwhich==1) {
    if(wav1==NULL)
      return 0;
    wav=wav1;
  } else if (iwhich==2) {
    if(wav2==NULL)
      return 0;
    wav=wav2;
  }


  strcpy(command,"aplay -q ");
  isize=sizeof(command)-strlen(command)-2;
  if(isize <= strlen(wav)) {
    if(iwhich==1)
      fprintf(stderr,"FS_ERROR_WAV string too big, max is %d\n",isize);
    else if(iwhich==2)
      fprintf(stderr,"FS_WAKEUP_WAV string too big, max is %d\n",isize);
    return -1;
  }
  strncat(command,wav,isize+1);
  strncat(command," &",3);
  system(command);

  return 0;
}
