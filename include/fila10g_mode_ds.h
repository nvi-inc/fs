/* mk5b_mode data structures */

struct fila10g_mode_cmd {
  struct {
    unsigned long mask;
    struct m5state state;
  } mask;
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
    int samplerate;
    struct m5state state;
  } samplerate;
};
