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
/*
 * rdbe_freqz.c
 *
 * Code generation for function 'rdbe_freqz'
 *
 * C source code generated on: Thu Jul 28 12:52:41 2016
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "rdbe_freqz.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
static real_T rt_hypotd_snf(real_T u0, real_T u1);

/* Function Definitions */
static real_T rt_hypotd_snf(real_T u0, real_T u1)
{
  real_T y;
  real_T a;
  real_T b;
  a = fabs(u0);
  b = fabs(u1);
  if (a < b) {
    a /= b;
    y = b * sqrt(a * a + 1.0);
  } else if (a > b) {
    b /= a;
    y = a * sqrt(b * b + 1.0);
  } else if (rtIsNaN(b)) {
    y = b;
  } else {
    y = a * 1.4142135623730951;
  }

  return y;
}

real_T rdbe_freqz(real_T f)
{
  real_T tmp_re;
  real_T tmp_im;
  int32_T k;
  real_T r;
  real_T ai;
  real_T re;
  static const int16_T iv0[256] = { -96, -115, -135, -154, -173, -192, -210,
    -228, -246, -262, -278, -293, -306, -317, -326, -333, -337, -338, -335, -328,
    -316, -300, -279, -252, -219, -180, -135, -84, -26, 38, 108, 183, 264, 350,
    439, 533, 629, 726, 824, 921, 1016, 1108, 1196, 1277, 1350, 1413, 1466, 1507,
    1533, 1544, 1538, 1514, 1471, 1407, 1322, 1215, 1086, 935, 761, 565, 347,
    109, -149, -425, -717, -1024, -1342, -1670, -2004, -2341, -2677, -3010,
    -3334, -3647, -3944, -4220, -4471, -4693, -4882, -5032, -5140, -5202, -5213,
    -5170, -5070, -4908, -4683, -4392, -4033, -3604, -3104, -2533, -1890, -1176,
    -392, 461, 1381, 2364, 3408, 4508, 5661, 6861, 8103, 9382, 10691, 12024,
    13373, 14733, 16094, 17450, 18792, 20114, 21407, 22664, 23877, 25039, 26142,
    27179, 28145, 29033, 29838, 30553, 31175, 31700, 32124, 32444, 32659,
    MAX_int16_T, MAX_int16_T, 32659, 32444, 32124, 31700, 31175, 30553, 29838,
    29033, 28145, 27179, 26142, 25039, 23877, 22664, 21407, 20114, 18792, 17450,
    16094, 14733, 13373, 12024, 10691, 9382, 8103, 6861, 5661, 4508, 3408, 2364,
    1381, 461, -392, -1176, -1890, -2533, -3104, -3604, -4033, -4392, -4683,
    -4908, -5070, -5170, -5213, -5202, -5140, -5032, -4882, -4693, -4471, -4220,
    -3944, -3647, -3334, -3010, -2677, -2341, -2004, -1670, -1342, -1024, -717,
    -425, -149, 109, 347, 565, 761, 935, 1086, 1215, 1322, 1407, 1471, 1514,
    1538, 1544, 1533, 1507, 1466, 1413, 1350, 1277, 1196, 1108, 1016, 921, 824,
    726, 629, 533, 439, 350, 264, 183, 108, 38, -26, -84, -135, -180, -219, -252,
    -279, -300, -316, -328, -335, -338, -337, -333, -326, -317, -306, -293, -278,
    -262, -246, -228, -210, -192, -173, -154, -135, -115, -96 };

  tmp_re = 0.0;
  tmp_im = 0.0;
  for (k = 0; k < 256; k++) {
    r = -0.0 * f;
    ai = -6.2831853071795862 * f;
    if (ai == 0.0) {
      re = r / 1.024E+9;
      r = 0.0;
    } else if (r == 0.0) {
      re = 0.0;
      r = ai / 1.024E+9;
    } else {
      re = r / 1.024E+9;
      r = ai / 1.024E+9;
    }

    ai = (real_T)k * r;
    r = exp((real_T)k * re / 2.0);
    tmp_re += (real_T)iv0[k] * (r * (r * cos(ai)));
    tmp_im += (real_T)iv0[k] * (r * (r * sin(ai)));
  }

  return rt_hypotd_snf(fabs(tmp_re), fabs(tmp_im)) / 1.079912E+6;
}

/* End of code generation (rdbe_freqz.c) */
