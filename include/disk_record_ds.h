/* mk5 disk_record data structures */

struct disk_record_cmd {
  struct {
    int record;
    struct m5state state;
  } record;
  struct {
    char scan[17];
    struct m5state state;
  } scan ;
  struct {
    char session[17];
    struct m5state state;
  } session ;
  struct {
    char source[17];
    struct m5state state;
  } source ;
  
};
struct disk_record_mon {
  struct {
    long scan;
    struct m5state state;
  } scan;
};
