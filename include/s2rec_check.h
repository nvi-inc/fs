/* s2 recorder error checking structure */

struct s2rec_check {
  int check;
  struct {
    int label[4];
    int field[4];
  } user_info;
  int speed;
  int state;
  int mode;
  int group;
  int roll;
  int dv;
  int tapeid;
  int tapetype;
};
