/* header file for lo data structures */

struct lo_cmd {     /* command parameters */
  double lo[4];     /* >=0 0 net freq in MHZ of total first LO,
                       < 0 this LO undefined */
  int sideband[4];  /* net sideband 0=unknown, 1=USB, 2=LSB */
  int pol[4];       /* polarization 0=unknown, 1=RCP, 2=LCP */
  double spacing[4]; /* >= 0 space in MHz, < 0 see pcal[] */
  double offset[4];  /* >= 0 offset of first tone in the IF */
  int pcal[4];      /* 0=unknown, 1 = off, undefined unless spacing[] < 0 */ 
};
