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
void int2str(output,ivalue,width,zorb)  /* integer point to string */
char *output;                           /* output string to append to */
int ivalue;                             /* value to convert */
int width;        /* maximum field width, >0 left justify, <0 right justify */
                  /* fewer than width characters may be used for left just. */
int zorb;         /* zeros or blanks, = 0 blank fill for non digit       */
                  /* positions, !=0 zero fill */
/* if output won't fit in specified width, that many characters are filled  */
/* with dollar signs */
/* this function is intended to be a replacement for FORTRAN ib2as routine */
{
      char form[30];   /* must be big enough to hold largest possible format */
      char string[256];/* must be big enough to hold largest possible integer*/

      char *ptr, zero[2], sign[2];
      int i,decpt, ndigit, wide, decd;

      output=output+strlen(output);     /* locate where to start filling */

      wide=width; strcpy(sign,"-");     /* handle justification */
      if(wide<0) {
        wide=-width;
        strcpy(sign,"");
      }

      decd=zorb; strcpy(zero,"");       /* handle padding */
      if(decd!=0) {
        decd=-zorb;
        strcpy(zero,"0");
      }

      if(zorb==0) decd=1;               /* make sure we get a decimal point */

      sprintf(form,"%%%s%s%dd",sign,zero,wide);  /* make format */
      sprintf(string,form,ivalue);                       /* do it */

      if(width>0) {                   /* trim trailing spaces for left-just. */
         ptr=strchr(string,' ');
         if(ptr!=NULL) *ptr='\0';
      }

      if(strlen(string)>wide) {     /* too wide, $ fill */
        for (i=0; i< wide; i++) 
          output[i]='$';
        output[wide]='\0';
        return;
      } else
        strcat(output,string);      /* okay, append result */

       return;
}
