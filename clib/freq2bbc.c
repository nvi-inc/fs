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
