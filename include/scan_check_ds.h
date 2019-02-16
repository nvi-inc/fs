/* mk5 data_check data structures */

struct scan_check_mon {

  /* command M5a and m5B parameters */

  struct {
    int scan;
    struct m5state state;
  } scan;
  struct {
    char label[65];
    struct m5state state;
  } label;
  struct {
    struct m5time start;
    struct m5state state;
  } start;
  struct {
    struct m5time length;
    struct m5state state;
  } length;
  struct {
    long long missing;
    struct m5state state;
  } missing ;

  /* m5a parameters */

  struct {
    char mode[33];
    struct m5state state;
  } mode;
  struct {
    char submode[33];
    struct m5state state;
  } submode ;
  struct {
    float rate;
    struct m5state state;
  } rate;

  /* m5b parameters */
  
  struct {
    char type[33];
    struct m5state state;
  } type;
  struct {
    int code;
    struct m5state state;
  }  code ;
  struct {
    float total;
    struct m5state state;
  } total;
  struct {
    char error[33];
    struct m5state state;
  } error;

};
