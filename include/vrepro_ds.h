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
/* header file for vlba reproduce function data structures */

struct vrepro_cmd {      /* command parameters */
                         /* indices run over channels a(0) and b(1) */
     int mode[2];        /* mode read(0) or byp(1) */
     int track[2];       /* track # 0-35 */
     int head[2];        /* head # 1 or 2 */
     int equalizer[2];   /* equalizer std(0), alt1(1), alt2(2) */
     int bitsynch;       /* 0...5 = 16, 8, 4, 2, 1, 0.5 Mbit/sec */
     };
