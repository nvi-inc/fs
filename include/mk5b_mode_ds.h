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
/* mk5b_mode data structures */

struct mk5b_mode_cmd {
  struct {
    int source;
    char magic[33];
    struct m5state state;
  } source;
  struct {
    unsigned long long mask;
    int bits;
    struct m5state state;
  } mask;
  struct {
    int decimate;
    unsigned long long datarate;
    struct m5state state;
  } decimate;
  struct {
    unsigned long long samplerate;
    int decimate;
    unsigned long long datarate;
    struct m5state state;
  } samplerate;
  struct {
    int fpdp;
    struct m5state state;
  } fpdp;
  struct {
    int disk;
    struct m5state state;
  } disk;
};

struct mk5b_mode_mon {
  struct {
    char format[33];
    struct m5state state;
  } format;
  struct {
    int tracks;
    struct m5state state;
  } tracks;
  struct {
    double tbitrate;
    struct m5state state;
  } tbitrate;
  struct {
    int framesize;
    struct m5state state;
  } framesize;
};
