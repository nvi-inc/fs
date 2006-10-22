/* mk5 data_check data structures */

struct data_check_mon {
  struct {
    char mode[33];
    struct m5state state;
  } mode;
  struct {
    char submode[33]; /* if mode is not tvg or SS */
    long first;      /* if mode is     tvg or SS */
    struct m5state state;
  } submode ;
  struct {
    struct m5time time;     /* if mode is not tvg or SS */
    long bad;        /* if mode is     tvg or SS */
    struct m5state state;
  } time;
  struct {
    long offset;     /* if mode is not tvg or SS */
    long size;       /* if mode is     tvg or SS */
    struct m5state state;
  } offset;
  struct {
    struct m5time period;
    struct m5state state;
  } period;
  struct {
    long bytes;
    struct m5state state;
  } bytes;
  struct {
    long long missing;
    struct m5state state;
  } missing ;
  
};
