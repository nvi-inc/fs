/* header file for s2 st data structures */

struct rec_mode_cmd {   /* command parameters */
  char mode[RCL_MAXSTRLEN_MODE];
  int group;
  int roll;
  int num_groups;
};
