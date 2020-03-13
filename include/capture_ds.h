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
/* header file for vlba capture data structures */

struct capture_mon {         /* monitor only parameters */
     struct {
        int drive;           /* drive in use 1 or 2 */
        int chan;            /* capture channel */
     } qa;
     struct {                /* general capture values from 0x48 & 0x49 */
       unsigned word1;
       unsigned word2;
     } general;
     struct {                /* time lsbs capture values from 0x4a & 0x4b */
       unsigned word3;
       unsigned word4;
     } time;
     };
