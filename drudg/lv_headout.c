#include <stdio.h>
#include <string.h>
/*
000110 nrv New. Copied from vlogx.
*/
void lv_headout(fp_out,station_name,station_id)

/* Input */
FILE *fp_out;
char *station_name;
char *station_id;

{
  fprintf(fp_out,"*FAKE Summary for %s. Station ID %s.\n",station_name,station_id);
  printf("*LVEX summary for %s. Station ID %s. \n",station_name,station_id);
  fprintf(fp_out,"*\n  def %s;   * %s\n",station_id,station_name);
  printf("  def %s   *%s\n",station_id,station_name);
}
