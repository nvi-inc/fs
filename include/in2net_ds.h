/* mk5 in2net data structures */

struct in2net_cmd {
  struct {
    int control;
    struct m5state state;
  } control;
  struct {
    char destination[33];
    struct m5state state;
  } destination ;
  struct {
    char options[33];
    struct m5state state;
  } options ;  
  char last_destination[33];
};

struct in2net_mon {
  struct {
    char status[33];
    struct m5state state;
  } status;
  struct {
    long long received;
    struct m5state state;
  } received;
  struct {
    long long buffered;
    struct m5state state;
  } buffered;
};
