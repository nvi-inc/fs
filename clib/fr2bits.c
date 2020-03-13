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
main()
{
    int i,freq, bits, bits2, freq2;
    int freq2bits();bits2freq();

    for (i=1;i<=0xFFFFF;i++) {
        bits=freq2bits(i);
        bits2=freq2bitsx(i);
        freq=bits2freq(bits);
        freq2=bits2freq(bits2);
      if(bits != bits2 || (i%0x10000 == 0))
        printf(" i %d bits %x freq %d % bits2 %x freq2 %d\n",i,bits,freq,
            bits2, freq2);
    }
}
int freq2bits(freq)
int freq;                    /* frequency in 10's of KHz, 50000-99999 legal */
{
    return( 0xFFFFF & ((~freq)+0x10) );
}
int freq2bitsx(freq)
int freq;                    /* frequency in 10's of KHz, 50000-99999 legal */
{
    int bits;

/*  return( 0xFFFFF & ((~freq)+0x10) );*/
    bits= ((0xFFFFF &~freq)+0x10);
    return (bits);

}
int bits2freq(bits)
unsigned int bits;
{
     return( 0xFFFFF & ~(bits-0x10));
}
