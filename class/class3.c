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

main()
{
int class, rtn1, rtn2, nchars,i;
char buffer[100];

    setup_ids();

    class=2;
    nchars=cls_rcv(class,buffer,100,&rtn1,&rtn2,0,0);

    printf(" '%.*s'\n",nchars,buffer);
    for (i=0;i<nchars;i++)
       printf("%o ",buffer[i]);

}
