#include <stdio.h>
#include <string.h>

/*
This routine writes out one scan in LVEX format.

000110 nrv New. Copied from vlogx
*/

void lv_scanout(fp_out,scanid,vsn,vhdpos,vstart,vfstart,vstop,vfstop,vsource)

/* Input */
FILE *fp_out;
char *scanid; /* scan ID */
char *vsn;    /* tape VSN */
char *vhdpos;  /* head position */
char *vstart; /* nnnnynnndnnhnnmnns */
char *vstop ; /* nnnnynnndnnhnnmnns */
char *vfstart ; /* starting footage */
char *vfstop  ; /* stoping footage */
char *vsource  ; /* source */

{ 
/* Local */

        fprintf(fp_out,"    scan %8s;\n",scanid);
        fprintf(fp_out,"      VSN = %s;\n",vsn);
        fprintf(fp_out,"      head_pos = %s um;\n",vhdpos);
        fprintf(fp_out,"      start_tape = %s : %s ft : 0 in/sec;\n",vstart,vfstart);
        fprintf(fp_out,"      stop_tape =  %s : %s ft ;\n",vstop,vfstop);
        fprintf(fp_out,"      source = %s;\n",vsource);
        fprintf(fp_out,"    endscan;\n");

}
