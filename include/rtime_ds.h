/* mk5 rtime data structures */

struct rtime_mon {
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
    char mode[6];
    struct m5state state;
  } mode;
  struct {
    char sub_mode[6];
    struct m5state state;
  } sub_mode;
  struct {
    double track_rate;
    struct m5state state;
  } track_rate;
  struct {
    double total_rate;
    struct m5state state;
  } total_rate;
};

