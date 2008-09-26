/* header file for mcbcn communication request buffers */

/* req_buf contains information pertaining to all request buffers */
/* req_rec contains information about a request */
/* these structures are manipulated bu req_util.c  */

#define REQ_BUF_MAX   512       /* maximum size of request buffer */

struct req_buf {                /* buffer structure */
     int count;                 /* number of buffers in class */
     long class_fs;                /* class number containing buffers */
     int nchars;                /* number of characters in buf */
     unsigned char buf[ REQ_BUF_MAX];    /* actual buffer */
     };

struct req_rec {                /* request structure */
     int type;                  /* request type */
     char device[2];            /* device mnemonic */
     unsigned addr;             /* address to access */
     unsigned data;             /* data if appropriate */
     };
