/* mk5 data_check data structures */

struct data_check_mon {

  /* common mk5a and mk5b parameters */

  struct {
    long long missing;
    struct m5state state;
  } missing ;

  /* mk5a parameters */

  struct {
    char mode[33];
    struct m5state state;
  } mode;
  struct {
    char submode[33]; /* if mode is not tvg or SS */
    int first;      /* if mode is     tvg or SS */
    struct m5state state;
  } submode ;
  struct {
    struct m5time time;     /* if mode is not tvg or SS */
    int bad;        /* if mode is     tvg or SS */
    struct m5state state;
  } time;
  struct {
    int offset;     /* if mode is not tvg or SS */
    int size;       /* if mode is     tvg or SS */
    struct m5state state;
  } offset;
  struct {
    struct m5time period;
    struct m5state state;
  } period;
  struct {
    int bytes;
    struct m5state state;
  } bytes;

  /* mk5b parameters */
  
  struct {
    char source[33];
    struct m5state state;
  } source;
  struct {
    struct m5time start;
    struct m5state state;
  } start;
  struct {
    int code;
    struct m5state state;
  } code ;
  struct {
    int frames;
    struct m5state state;
  } frames;
  struct {
    struct m5time header;
    struct m5state state;
  } header;
  struct {
    float total;
    struct m5state state;
  } total;
  struct {
    int byte;
    struct m5state state;
  } byte;

};
