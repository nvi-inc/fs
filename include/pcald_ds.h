/* header file for pcald data structures */

struct pcald_cmd {
  int continuous;          /* 0 = controled by data_valid, 1 = continuous */
  int bits;                /* 0 = "best", 1,2 = 1,2 bit extraction */
  int integration;         /* integration period in centi-seconds
                              0 = nominal phase error less than 1 degree */
  int stop_request;
  int count[2][16];        /* number of tones for [u...l][1...16] */
  double freqs[2][16][17]; /* list of frequencies, < 0 for state counting */
};

