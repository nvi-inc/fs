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
/* header file for holog data structures */

struct satellite_cmd {
  char name[25];        /* name */
  char tlefile[65];     /* tle file name in /usr2/control/tle_files */
  int mode;             /* pointing mode, 0=track, 1=radec, 2=azel */
  int wrap;             /* cable wrap, 0=neutral, 1=ccw, 2=cw */
  int satellite;        /* 1=satellite, 0=source */
  char tle0[25];        /* common name of suucessfully processed satellite */
  char tle1[70];        /* TLE1 of suucessfully processed satellite */
  char tle2[70];        /* TLE2 of suucessfully processed satellite */
};

struct satoff_cmd {
  double seconds;         /* along track offset, in seconds of time */
  double cross;           /* cross track offset, radians */
  int hold;               /* 0=track, 1=hold*/
};

struct satellite_ephem {
  int t;             /* unix time of position, seconds resolution */
  double az;          /* azimuth */
  double el;          /* elevation */
};

struct tle_cmd {
  char tle0[25];      /* common name */
  char tle1[70];      /* TLE Line 1 */
  char tle2[70];      /* TLE Line 1 */
  int catnum[3];     /* catalog number for each line */
};
