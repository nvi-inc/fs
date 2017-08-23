/* mk5b_mode data structures */

struct fila10g_mode_cmd {
  struct {
    unsigned long mask2;
    struct m5state state;
  } mask2;
  struct {
    unsigned long mask1;
    struct m5state state;
  } mask1;
  struct {
    int decimate;
    struct m5state state;
  } decimate;
  struct {
    int disk;
    struct m5state state;
  } disk;
};

struct fila10g_mode_mon {
  struct {
    int clockrate;
    struct m5state state;
  } clockrate;
};
