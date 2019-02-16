/* s2-DAS error checking structure */

struct s2das_check {
  unsigned int check;
  char agc;
  char encode;
  char mode[21];
  char FSstatus, SeqName[25];
  char BW;
};
