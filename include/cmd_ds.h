/* header file for snap command data structure for parsing utilities */

/* cmd_ds is used to hold information about the tokens in a snap command */

#define MAX_ARGS  100        /* maximum number of args after `=' */

struct cmd_ds {              /* command data structure */
      char *name;            /* pointer to command name STRING */
      char equal;            /* '=' if '=' follows command name,
                                '\0' otherwise */
      char *argv[MAX_ARGS];  /* pointers to argument STRINGS,
                                vaild data terminated by a NULL pointer */
      };
