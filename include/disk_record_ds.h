/* mk5 disk_record data structures */

struct disk_record_cmd {
  struct {
    int record;
    struct m5state state;
  } record;
  struct {
    char label[65];
    struct m5state state;
  } label ;
  
};
struct disk_record_mon {
  struct {
    char status[33];
    struct m5state state;
  } status ;
  struct {
    long scan;
    struct m5state state;
  } scan;
};
