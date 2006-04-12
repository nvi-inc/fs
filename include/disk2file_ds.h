/* mk5 disk2file data structures */

struct disk2file_cmd {
  struct {
    char scan_label[65];
    struct m5state state;
  } scan_label;
  struct {
    char destination[129];
    struct m5state state;
  } destination ;
  struct {
    char start[33];
    struct m5state state;
  } start ;
  struct {
    char end[33];
    struct m5state state;
  } end ;
  struct {
    char options[33];
    struct m5state state;
  } options ;  
};

struct disk2file_mon {
  struct {
    int scan_number;
    struct m5state state;
  } scan_number;
  struct {
    char option[33];
    struct m5state state;
  } option;
  struct {
    long long start_byte;
    struct m5state state;
  } start_byte;
  struct {
    long long end_byte;
    struct m5state state;
  } end_byte;
  struct {
    char status[33];
    struct m5state state;
  } status;
  struct {
    long long current;
    struct m5state state;
  } current ;
};
