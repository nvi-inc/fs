/* ifatt.ctl shared memory (C data structure) layout

struct ifatt_shm {
  int num_of_entry;        * number of entries *
  char mode_name[16];      * mode set by if_mode snap cmd *
  char ifmode[100][16];    * mode name *
  int attenuator[3][100];  * [0]=if1, [1]=if2, [2]=if3 *
};

*/
