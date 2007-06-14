/* mk5 dot data structures */

struct dot_mon {
  struct {
    char time[33];
    struct m5state state;
  } time ;
  struct {
    char status[33];
    struct m5state state;
  } status ;
  struct {
    char FHG_status[33];
    struct m5state state;
  } FHG_status ;
  struct {
    char OS_time[33];
    struct m5state state;
  } OS_time ;
  struct {
    char DOT_OS_time_diff[33];
    struct m5state state;
  } DOT_OS_time_diff ;
};
