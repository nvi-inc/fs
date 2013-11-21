/* mk6 disk_pos data structures */

struct mk6_disk_pos_mon {
  struct {
    long long record;
    struct m5state state;
  } record;
  struct {
    long long play;
    struct m5state state;
  } play;
  struct {
    long long stop;
    struct m5state state;
  } stop;
};
