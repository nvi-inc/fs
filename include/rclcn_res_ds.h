/* header file for rclcn response data structures */

#define RCLCN_RES_MAX_BUF  512

struct rclcn_res_buf {
  int class;
  int count;
  int ifc;
  int nchars;
  unsigned char buf[ RCLCN_RES_MAX_BUF];
};

union pos_union {
  struct {
    long int position;
    long int posvar;
  } overall;
  struct {
    int num_entries;
    long int position[8];
  } individual;
};
