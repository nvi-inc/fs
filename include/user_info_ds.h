/* header file for vlba st data structures */

struct user_info_parse {
  int field;             /* parsed field value */
  int label;             /* TRUE for label, FALSE for field */
  char string[49];       /* parsed string */
};

struct user_info_cmd {   /* command parameters */
  char labels[4][17];       /* label strings */
  char field1[17];       /* field1 string */
  char field2[17];       /* field2 string */
  char field3[33];       /* field3 string */
  char field4[49];       /* field4 string */
};
