/* mk5 1pps_source data structures */

struct pps_source_cmd {
  struct {
    char source[33];
    struct m5state state;
  } source ;
};
