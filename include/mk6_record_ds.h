/* mk6_record data structures */

struct mk6_record_cmd {
  struct {
    /*  ####y###d##h##m##.##s\0 
        1234567890123456789012 */
    char action[22];
    struct m5state state;
  } action;
  struct {
    int duration;
    struct m5state state;
  } duration ;
  struct {
    int size;
    struct m5state state;
  } size;
  struct {
    char scan[33];
    struct m5state state;
  } scan;
  struct {
    char experiment[9];
    struct m5state state;
  } experiment;
  struct {
    char station[9];
    struct m5state state;
  } station;
  
};
struct mk6_record_mon {
  struct {
    char status[33];
    struct m5state state;
  } status ;
  struct {
    int group;
    struct m5state state;
  } group;
  struct {
    int number;
    struct m5state state;
  } number;
  struct {
    char name[33];
    struct m5state state;
  } name;
};
