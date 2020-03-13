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
/* echoe.c - echo expansion of non printing chars */

#include <memory.h>
#include <string.h>

/* echoe expands a array of characters, replacing non-printing
 * characters with a sequence of [x] where x is a 2 or 3 character
 * mnemonic for the non-printing character, thus the output can be
 * a maximum of 5 times the number characters input
 *
 * input:
 *    inbuf - character data to be expanded
 *    inchar  - number of characters in inbuf
 *    maxout  - maximum number of characters that can fit in iebuf
 *
 * output:
 *    iebuf   - echo expansion of inbuf
 *    outchar - number of characters in iebuf, never exceeds maxout
 */

void echoe(inbuf,iebuf,inchar,outchar,maxout)
char *inbuf,*iebuf;
int inchar,*outchar,maxout;
{
      static char *exp[] = {
               "nul","soh","stx","etx","eot","enq","ack","bel",
               "bs" ,"ht" ,"lf" ,"vt" ,"ff" ,"cr" ,"so" ,"si" ,
               "dle","dc1","dc2","dc3","dc4","nak","syn","etb",
               "can","em" ,"sub","esc","fs" ,"gs" ,"rs" ,"us" };

      int inext,i,ilen,ich;
      char iobuf[6];

      inext=0;
      for (i=0;i<inchar;i++) {
        ich= 0177 & inbuf[i];
        if(ich>31 && ich != 127) {
          iobuf[0]=ich;
          ilen=1;
        } else if (ich < 32) {
          iobuf[0]='[';
          memccpy(iobuf+1,exp[ich],'\0',4);
          strcat(iobuf,"]");
          ilen=strlen(iobuf);
        } else {
          strcpy(iobuf,"[del]");
          ilen=5;
        }
        if(ilen+inext < maxout) {
          memcpy(iebuf+inext,iobuf,ilen);
          inext+= ilen;
        }
      }
      *outchar=inext;

      return;
}
