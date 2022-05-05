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
/*  @(#)bblvcode.c  version 1.1  created 90/01/21 14:47:03
%% functions to convert BBC level code to dB, and vice versa
:: baseband converter bblvdB
*/

/* internals */
int bblvcode ();	/* return code for given level */

/* lookup table for level conversions */
static double table[] = 
  { -99.99, -36.16, -30.14, -26.62, -24.12, -22.18, -20.60, -19.26, 
    -18.10, -17.08, -16.16, -15.34, -14.58, -13.89, -13.24, -12.64, 
    -12.08, -11.56, -11.06, -10.59, -10.14,  -9.72,  -9.32,  -8.93, 
     -8.56,  -8.21,  -7.86,  -7.54,  -7.22,  -6.92,  -6.62,  -6.34, 
     -6.06,  -5.79,  -5.53,  -5.28,  -5.04,  -4.80,  -4.57,  -4.34, 
     -4.12,  -3.91,  -3.70,  -3.49,  -3.30,  -3.10,  -2.91,  -2.72, 
     -2.54,  -2.36,  -2.18,  -2.01,  -1.84,  -1.68,  -1.52,  -1.36, 
     -1.20,  -1.05,  -0.90,  -0.75,  -0.60,  -0.46,  -0.32,  -0.18, 
     -0.04,   0.09,   0.23,   0.36,   0.49,   0.61,   0.74,   0.86, 
      0.98,   1.10,   1.22,   1.34,   1.45,   1.57,   1.68,   1.79, 
      1.90,   2.01,   2.11,   2.22,   2.32,   2.42,   2.53,   2.63, 
      2.73,   2.82,   2.92,   3.02,   3.11,   3.21,   3.30,   3.39, 
      3.48,   3.57,   3.66,   3.75,   3.84,   3.92,   4.01,   4.09, 
      4.18,   4.26,   4.34,   4.42,   4.50,   4.58,   4.66,   4.74, 
      4.82,   4.90,   4.97,   5.05,   5.12,   5.20,   5.27,   5.35, 
      5.42,   5.49,   5.56,   5.63,   5.70,   5.77,   5.84,   5.91, 
      5.98,   6.05,   6.11,   6.18,   6.25,   6.31,   6.38,   6.44, 
      6.51,   6.57,   6.63,   6.70,   6.76,   6.82,   6.88,   6.94, 
      7.00,   7.06,   7.12,   7.18,   7.24,   7.30,   7.36,   7.42, 
      7.47,   7.53,   7.59,   7.64,   7.70,   7.75,   7.81,   7.86, 
      7.92,   7.97,   8.03,   8.08,   8.13,   8.19,   8.24,   8.29, 
      8.34,   8.39,   8.44,   8.50,   8.55,   8.60,   8.65,   8.70, 
      8.75,   8.80,   8.84,   8.89,   8.94,   8.99,   9.04,   9.08, 
      9.13,   9.18,   9.23,   9.27,   9.32,   9.37,   9.41,   9.46, 
      9.50,   9.55,   9.59,   9.64,   9.68,   9.73,   9.77,   9.81, 
      9.86,   9.90,   9.94,   9.99,  10.03,  10.07,  10.11,  10.16, 
     10.20,  10.24,  10.28,  10.32,  10.36,  10.40,  10.44,  10.48, 
     10.52,  10.56,  10.60,  10.64,  10.68,  10.72,  10.76,  10.80, 
     10.84,  10.88,  10.92,  10.96,  10.99,  11.03,  11.07,  11.11, 
     11.15,  11.18,  11.22,  11.26,  11.29,  11.33,  11.37,  11.40, 
     11.44,  11.48,  11.51,  11.55,  11.58,  11.62,  11.65,  11.69, 
     11.72,  11.76,  11.79,  11.83,  11.86,  11.90,  11.93,  11.97
  };

/********************************************************************/
int bblvcode (dB)	/* return BBC hardware code for given level */
double dB;
/*
* RETURNS
-*/
{
    int i;

    for (i = 0; i < 256; i++)
	if (dB <= table[i])
	    break;
    return (i);
}

/*++****************************************************************************
*/
double bblvdB (code)	/* return level (dB) corresponding to code */
int code;	/* filter code in upper byte, gain code in lower */
{
    if (code > 255)
	code = 0;
    if (code < 0)
	code = 255;
    return (table[code]);
}
