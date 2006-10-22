/* mk5 bank_set data structures */

struct bank_set_mon {
  struct {
    char active_bank[33];
    struct m5state state;
  } active_bank;
  struct {
    char active_vsn[33];
    struct m5state state;
  } active_vsn;
  struct {
    char inactive_bank[33];
    struct m5state state;
  } inactive_bank;
  struct {
    char inactive_vsn[33];
    struct m5state state;
  } inactive_vsn;
};

