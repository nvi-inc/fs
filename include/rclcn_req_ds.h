/* header file for mcbcn communication request buffers */

/* rcl_req_buf contains information pertaining to all request buffers */
/* these structures are manipulated buy rcl_req_util.c  */

#define RCLCN_REQ_BUF_MAX   512       /* maximum size of request buffer */

struct rclcn_req_buf {            /* buffer structure */
  int count;                 /* number of buffers in class */
  long class;                /* class number containing buffers */
  int nchars;                /* number of characters in buf */
  int prev_nchars;
  unsigned char buf[ RCLCN_REQ_BUF_MAX];    /* actual buffer */
};

