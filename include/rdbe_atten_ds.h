/* rdbe_atten data structures */

struct rdbe_atten_cmd {
  struct {
    int if0;
    struct m5state state;
  }  if0;
  struct {
    int if1;
    struct m5state state;
  }  if1;
  
};
