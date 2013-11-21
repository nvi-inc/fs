/* rdbe dot data structures */

struct rdbe_dot_mon {
  struct {
    char time[33];
    struct m5state state;
  } time ;
  struct {
    char status[33];
    struct m5state state;
  } status ;
  struct {
    char OS_time[33];
    struct m5state state;
  } OS_time ;
  struct {
    char DOT_OS_time_diff[33];
    struct m5state state;
  } DOT_OS_time_diff ;
  struct {
    char Actual_DOT_time[33];
    struct m5state state;
  } Actual_DOT_time ;
};
