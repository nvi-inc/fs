/* rdbe_atten data structures */

struct rdbe_atten_cmd {
  struct {
    int ifc;
    struct m5state state;
  }  ifc;
  struct {
    int atten;
    struct m5state state;
  }  atten;
  struct {
    float target;
    struct m5state state;
  }  target;
  
};
struct rdbe_atten_mon {
  struct {
    struct {
      int ifc;
      struct m5state state;
    }  ifc;
    struct {
      int atten;
      struct m5state state;
    }  atten;
    struct {
      float RMS;
      struct m5state state;
    }  RMS;
  } ifc[2];
  
};
