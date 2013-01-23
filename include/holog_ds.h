/* header file for holog data structures */

struct holog_cmd {
  float az, el;          /* span */
  int azp, elp;         /* points per axis */
  int ical;             /* seconds after which to cal */
  char proc[33];        /* procedure for each point */
  int stop_request;     /* stop request issued? */
  int setup;            /* have we been set-up */
  int wait;             /* onsource wait */
};

