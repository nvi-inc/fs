/* header file for mcb command data structure */

struct mcb_cmd {    /* mcb command data struct */
   char device[2];   /* device to access, "\0" if addr is absolute */
   unsigned addr;    /* relative address in module */
   unsigned data;    /* data to send if cmd != 0 */
   int cmd;          /* =1 to cmd and =0 to read */
};

struct mcb_mon {
   unsigned data;    /* response data */
};
