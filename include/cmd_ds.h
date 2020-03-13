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
/* header file for snap command data structure for parsing utilities */

/* cmd_ds is used to hold information about the tokens in a snap command */

#define MAX_ARGS  100        /* maximum number of args after `=' */

struct cmd_ds {              /* command data structure */
      char *name;            /* pointer to command name STRING */
      char equal;            /* '=' if '=' follows command name,
                                '\0' otherwise */
      char *argv[MAX_ARGS];  /* pointers to argument STRINGS,
                                vaild data terminated by a NULL pointer */
      };
