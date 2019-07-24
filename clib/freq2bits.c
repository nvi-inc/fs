long unsigned freq2bits(freq)
long freq;                    /* frequency in 10's of KHz, 50000-99999 legal */
{
    return( 0xFFFFF & ((~(unsigned) freq)+0x10) );
}
long bits2freq(bits)
long unsigned bits;
{
     return( ~(bits-0x10));
}
