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
/* 04.06.23 AEM changes <sys/termio.h> -> <termio.h>
 04.06.23 AEM remove pointer from function (*fc_gwinsz -> fc_gwinsz)
 ?! why here was '*', not clear yet...
   ../sked/skcom.ftni : integer iwscn
   ../sked/prset.f : integer fc_gwinsz; iwscn = fc_gwinsz()
*/
#include <termio.h>

#ifdef _NEEDED
int fc_gwinsz_()
#else
int fc_gwinsz()
#endif
{
     struct winsize ws;
     int *winlen;

     ioctl(0,TIOCGWINSZ,&ws);
     /* unsigned short int ws.ws_row */
     return((int) ws.ws_row);
}
