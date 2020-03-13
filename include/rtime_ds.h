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
/* mk5 rtime data structures */

struct rtime_mon {

/* mark 5a and 5b common members */

  struct {
    double seconds;
    struct m5state state;
  } seconds;
  struct {
    double gb;
    struct m5state state;
  } gb;
  struct {
    double percent;
    struct m5state state;
  } percent;
  struct {
    double total_rate;
    struct m5state state;
  } total_rate;

  /* mark5a unique members */

  struct {
    char mode[33];
    struct m5state state;
  } mode;
  struct {
    char sub_mode[33];
    struct m5state state;
  } sub_mode;
  struct {
    double track_rate;
    struct m5state state;
  } track_rate;

  /* mark5b unique members */

  struct {
    char source[33];
    struct m5state state;
  } source;
  struct {
    unsigned int mask;
    struct m5state state;
  } mask;
  struct {
    int decimate;
    struct m5state state;
  } decimate;
};

