/* header file for pcalform data structures */

struct pcalform_cmd {
    int count[2][16];       /* number of tones for [u...l][1...16] */
    int which[2][16][17];   /* non-zero if this value uses "tones"
                               zero if this value uses freqs */
    int tones[2][16][17];   /* list of tones */
    int strlen[2][16][17];  /* length of input tone/freq input arg to aid
                               display */
    double freqs[2][16][17];/* list of frequencies */
};


