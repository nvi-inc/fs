/* mk5 data_check data structures */

struct scan_check_mon {
  struct {
    long scan;
    struct m5state state;
  } scan;
  struct {
    char label[65];
    struct m5state state;
  } label;
  struct {
    char mode[33];
    struct m5state state;
  } mode;
  struct {
    char submode[33];
    struct m5state state;
  } submode ;
  struct {
    struct m5time start;
    struct m5state state;
  } start;
  struct {
    struct m5time length;
    struct m5state state;
  } length;
  struct {
    float rate;
    struct m5state state;
  } rate;
  struct {
    long long missing;
    struct m5state state;
  } missing ;
  
};
