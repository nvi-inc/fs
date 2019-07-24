/* bbc freq conversion utilities */
/* the bbc units are 20 bits of (15-freq), where freq is 10s of KHz */

long freq2bbc(freq)           /* frequency to bits conversion */
long freq;                    /* frequency in 10's of KHz, 50000-99999 legal */
{
    return 0xFFFFF & (-(freq/10) << 4 | 0xF & ~(freq%10));
}
long bbc2freq(bits)           /* bits to frequency */
long unsigned bits;
{
     return -(~0xFFFF | bits>>4)*10+ (0xF & ~bits);

}
