/* dbbc vsi_clck dot data structures */

struct dbbcvsi_clk_mon {
  struct {
    int vsi_clk;
    struct m5state state;
  } vsi_clk;
};
