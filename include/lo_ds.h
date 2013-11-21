/* header file for lo data structures */

struct lo_cmd {     /* command parameters */
  double lo[MAX_LO];      /* >=0 0 net freq in MHZ of total first LO,
                             < 0 this LO undefined */
  int sideband[MAX_LO];   /* net sideband 0=unknown, 1=USB, 2=LSB */
  int pol[MAX_LO];        /* polarization 0=unknown, 1=RCP, 2=LCP */
  double spacing[MAX_LO]; /* >= 0 space in MHz, < 0 see pcal[] */
  double offset[MAX_LO];  /* >= 0 offset of first tone in the IF */
  int pcal[MAX_LO];       /* 0=unknown, 1 = off, undefined unless spacing[] < 0 */ 
};
