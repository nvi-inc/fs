/* header file for k4 vc data structures */

struct k4vc_cmd {   /* command parameters */
  int lohi[16];
  int att[16];
  int loup[16];
};

struct k4vc_mon {   /* monitor parameters */
  char yes[16];
  int usbpwr[16];
  int lsbpwr[16];
};
