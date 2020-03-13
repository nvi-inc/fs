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
/* initvstr.c - initialize VLBA strings */

#include <memory.h>
#include "../include/params.h"

char setcmd[] =  {0,'f','m',0x00,0xa8,0x00,0x00,  /* time years */
                  0,'f','m',0x00,0xa9,0x00,0x00,  /* time days  */
                  0,'f','m',0x00,0xaa,0x00,0x00,  /* time hours */
                  0,'f','m',0x00,0xab,0x00,0x00}; /* time min, sec */

void initvstr()
{
/* initialize command strings with formatter mnemonic */
memcpy (setcmd+ 1, DEV_VFM, 2);
memcpy (setcmd+ 8, DEV_VFM, 2);
memcpy (setcmd+15, DEV_VFM, 2);
memcpy (setcmd+22, DEV_VFM, 2);
}
