/* Mark IV formmatter data structures */

struct vsi4_cmd {
  struct vsi4 {
    int value;        /* 0=vlba,geo,tvg */
    int set;
  } config;
  struct vsi4 pcalx;         /* 1-14 VC/BBC */
  struct vsi4 pcaly;         /* 1-14 VC/BBC */
};

struct vsi4_mon {
  int version;      /* version number */
};
