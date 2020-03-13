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
/* bbc freq conversion utilities */
/* the bbc units are 20 bits of (15-freq), where freq is 10s of KHz */
/* the calculation works for 0.10-6553.69 MHz, but the LO locks over */
/* a range more like 470.-1050. MHz */

int freq2bbc(freq)        /* frequency to bits conversion */
int freq;                 /* frequency in 10's of KHz, 45000-105000 typical */
{
    return 0xFFFFF & (-(freq/10) << 4 | 0xF & ~(freq%10));
}
int bbc2freq(bits)           /* bits to frequency */
unsigned int bits;
{
     return -(~0xFFFF | bits>>4)*10+ (0xF & ~bits);

}
