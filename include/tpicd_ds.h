/* header file for pcald data structures */

struct tpicd_cmd {
  int continuous;          /* 0 = controled by data_valid, 1 = continuous */
  int cycle;                  /* cycle period in centi-seconds */
  int stop_request;
  int itpis[2*16+4];
  int ifc[2*16+4];
  char lwhat[2*16+4][2];
};

