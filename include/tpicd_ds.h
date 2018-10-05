/* header file for pcald data structures */

struct tpicd_cmd {
  int continuous;          /* 0 = controled by data_valid, 1 = continuous */
  int cycle;                  /* cycle period in centi-seconds */
  int stop_request;
  int itpis[MAX_TSYS_DET];
  int ifc[MAX_TSYS_DET];
  char lwhat[MAX_TSYS_DET][4];
  int tsys_request;
};

