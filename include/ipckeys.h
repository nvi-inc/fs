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
/* IPC keys parameter header */

#ifdef NO_FTOK_FS
#define SHM_KEY     1
#define CLS_KEY     2
#define SKD_KEY     3
#define BRK_KEY     4
#define SEM_KEY     5
#define NSEM_KEY    6
#define GO_KEY      7
#else
#define SHM_KEY     ftok("/usr2/fs",1)
#define CLS_KEY     ftok("/usr2/fs",2)
#define SKD_KEY     ftok("/usr2/fs",3)
#define BRK_KEY     ftok("/usr2/fs",4)
#define SEM_KEY     ftok("/usr2/fs",5)
#define NSEM_KEY    ftok("/usr2/fs",6)
#define GO_KEY      ftok("/usr2/fs",7)
#endif

