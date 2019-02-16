/* mk5b_mode data structures */

struct mk5b_mode_cmd {
  struct {
    int source;
    struct m5state state;
  } source;
  struct {
    unsigned int mask;
    struct m5state state;
  } mask;
  struct {
    int decimate;
    struct m5state state;
  } decimate;
  struct {
    int fpdp;
    struct m5state state;
  } fpdp;
  struct {
    int disk;
    struct m5state state;
  } disk;
};
