/* mk5b_mode data structures */

struct mk5b_mode_cmd {
  struct {
    int source;
    char magic[33];
    struct m5state state;
  } source;
  struct {
    unsigned long long mask;
    struct m5state state;
  } mask;
  struct {
    int decimate;
    struct m5state state;
  } decimate;
  struct {
    float samplerate;
    int decimate;
    struct m5state state;
  } samplerate;
  struct {
    int fpdp;
    struct m5state state;
  } fpdp;
  struct {
    int disk;
    struct m5state state;
  } disk;
};

struct mk5b_mode_mon {
  struct {
    char format[33];
    struct m5state state;
  } format;
  struct {
    int tracks;
    struct m5state state;
  } tracks;
  struct {
    float tbitrate;
    struct m5state state;
  } tbitrate;
  struct {
    int framesize;
    struct m5state state;
  } framesize;
};
