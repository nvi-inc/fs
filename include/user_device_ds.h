/* header file for user_device data structures */

struct user_device_cmd {     /* command parameters */
  double lo[6];     /* >=0 0 net freq in MHZ of total first LO,
                                  < 0 this device undefined */
  int sideband[6];  /* net sideband 0=unknown, 1=USB, 2=LSB */
  int pol[6];       /* polarization 0=unknown, 1=RCP, 2=LCP */
  double center[6]; /* detector center frequency */
};
