/* mk5 disk_serial data structures */

#define MK5_DISK_SERIAL_MAX 16
#define MK5_DISK_SERIAL_BYTES 33

struct disk_serial_mon {
  int count;
  struct {
    char serial[MK5_DISK_SERIAL_BYTES];
    struct m5state state;
  } serial[MK5_DISK_SERIAL_MAX];
  
};
