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
/* dbbc3 ifX data structures */

struct dbbc3_ifx_cmd {
     int input;        /* channel: 1, 2, 3, 4 */
     int att;          /* attenuation, steps 0-64; -1==NULL */
     int agc;          /* gain control 0=man, 1=agc */
     int target_null;  /* 1==NULL */
     unsigned target;  /* target value for AGC, 0-65535 */
    };

struct dbbc3_ifx_mon {
     unsigned tp;      /* tpi , 0-65535 counts */
    };
