/* mk5 clock_set data structures */

struct clock_set_cmd {
  struct {
    int freq;
    struct m5state state;
  } freq ;
  struct {
    char source[33];
    struct m5state state;
  } source ;
  struct {
    double clock_gen;
    struct m5state state;
  } clock_gen ;
};
