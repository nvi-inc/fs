/* header file for k4 pcalports data structures */

struct k4pcalports_cmd {   /* command parameters */
  int ports[2];
};

struct k4pcalports_mon {   /* monitor parameters */
  float amp[2];
  float phase[2];
};

