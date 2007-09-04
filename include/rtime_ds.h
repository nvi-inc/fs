/* mk5 rtime data structures */

struct rtime_mon {

/* mark 5a and 5b common members */

  struct {
    double seconds;
    struct m5state state;
  } seconds;
  struct {
    double gb;
    struct m5state state;
  } gb;
  struct {
    double percent;
    struct m5state state;
  } percent;
  struct {
    double total_rate;
    struct m5state state;
  } total_rate;

  /* mark5a unique members */

  struct {
    char mode[33];
    struct m5state state;
  } mode;
  struct {
    char sub_mode[33];
    struct m5state state;
  } sub_mode;
  struct {
    double track_rate;
    struct m5state state;
  } track_rate;

  /* mark5b unique members */

  struct {
    char source[33];
    struct m5state state;
  } source;
  struct {
    unsigned long mask;
    struct m5state state;
  } mask;
  struct {
    int decimate;
    struct m5state state;
  } decimate;
};

