struct fila10g_cmd {
  char *cmd;
  struct fila10g_cmd *next;
};
struct fila10g_cfg {
  char *name;
  struct fila10g_cmd *cmd;
  struct fila10g_cfg *next;
};
