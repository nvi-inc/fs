/* mk5 vsn data structures */

struct vsn_mon {
  struct {
    char vsn[33];
    struct m5state state;
  } vsn;
  struct {
    char check[33];
    struct m5state state;
  } check;
  struct {
    int disk;
    struct m5state state;
  } disk;
  struct {
    char original_vsn[33];
    struct m5state state;
  } original_vsn;
  struct {
    char new_vsn[33];
    struct m5state state;
  } new_vsn;
};
