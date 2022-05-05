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
/* rp2codek42.c determines recorder port inputs for k42 rack */

#include <stdio.h>

static char *channel[ 32]= {
  "a1l",  "a1u",
  "a2l",  "a2u",
  "a3l",  "a3u",
  "a4l",  "a4u",
  "a5l",  "a5u",
  "a6l",  "a6u",
  "a7l",  "a7u",
  "a8l",  "a8u",
  "b1l",  "b1u",
  "b2l",  "b2u",
  "b3l",  "b3u",
  "b4l",  "b4u",
  "b5l",  "b5u",
  "b6l",  "b6u",
  "b7l",  "b7u",
  "b8l",  "b8u"
};

int rp2codek42(bs)
char *bs;
{
  int i;

  if (bs == NULL)
    return 0;

  if (strcmp(bs,"0")==0)
    return 0;

  if (strcmp(bs,"")==0)
    return 0;

  for (i=0;i<(sizeof(channel)/sizeof(char *)); i++)
    if (strcmp(bs,channel[i])==0)
      if(i%2==0)
	return -(i/2+1);
      else
	return i/2+1;

  return 0;
}

char *code2rpk42(pin)
int pin;
{
  static char zero[]= "0";

  if(pin < -14 || pin > 14 || pin == 0)
    return zero;
  else if(pin <0)
    return channel[(-pin-1)*2];
  else
    return channel[(pin-1)*2+1];

}
  
