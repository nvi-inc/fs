/* header file for s2 recorder label data structures */

struct s2label_cmd {   /* command parameters */
  char tapeid[RCL_MAXSTRLEN_TAPEID];
  char tapetype[RCL_MAXSTRLEN_TAPETYPE];
  char format[33];
};
