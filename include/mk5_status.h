/*
 * Copyright (c) 2025 NVI, Inc.
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

/* mk5 mk5_status SNAP command defines */

/*
 * The original '5B' errors should be a guideline of what is typical eg.
 * -301 is when you are sent a parameter as you surmised, but you should add
 *  a 5H -301 to match
 *
 *  [16/01/15 10:38:55] Jonathan Quick: Then the -500 errors codes document
 *  things that went wrong whilst enacting the command, so most of yours
 *  belong in that range ... the <n> there is just the nth possible error so
 *  its -501,-502,... for as many distinct errors as you need.
 *
 *  [16/01/15 10:39:38] Jonathan Quick: and the -40x document when the
 *  internal FS class message passing mechanism lets you down
 *
 *  [16/01/15 10:42:46] Jonathan Quick: The -9<n>x appear to be marking
 *  errors in parsing the <n>th underlying command (to the Mark5) so -90x
 *  for the 'status?' and then -91x for the 'error?' say
 */

#define EPARM           (-301) /* "command does not accept parameters" */
#define ECLASS          (-401) /* "error retrieving class" */
#define ENREPLY         (-501) /* "wrong number of replies" */
#define EFORMAT_STATUS  (-900) /* "query response bad format" for "status?" query */
#define ESTATUSWORD     (-901) /* "error decoding status word" */
#define EFORMAT_ERROR   (-910) /* "query response bad format" for "error?" query */
#define ESTRDUP_ERROR   (-912) /* "strdup failed" */
