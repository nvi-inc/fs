/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* lo buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void log_rxgfile(lo)
    int lo;
{
    int ir, i, iend;

    size_t start;
    char output[256];

    ir=get_gain_rxg(lo+1,&shm_addr->lo);
    if(ir<0)
        return;
    
    if (shm_addr->rxgain_files[ir].logged)
        return;
    else
        shm_addr->rxgain_files[ir].logged=TRUE;

    strcpy(output,"rxg_file,");
    strcat(output,shm_addr->rxgain_files[ir].file);
    strcat(output,",");
    start=strlen(output);

    /* line 1: LOs */

    output[start]=0;
    if(shm_addr->rxgain[ir].type=='f')
        strcat(output,"fixed");
    else if(shm_addr->rxgain[ir].type=='r')
        strcat(output,"range");
    strcat(output,",");
    snprintf(output+strlen(output),
            sizeof(output)-strlen(output),
            "%.6f",shm_addr->rxgain[ir].lo[0]);

    if(shm_addr->rxgain[ir].lo[1]>=0) {
        strcat(output,",");
        snprintf(output+strlen(output),
                sizeof(output)-strlen(output),
                "%.6f",shm_addr->rxgain[ir].lo[1]);
    }


    logit_nds(output,0,NULL,':');

    /* line 2: date */

    output[start]=0;
    snprintf(output+strlen(output),
            sizeof(output)-strlen(output),
            "%d,%d,%d",
            shm_addr->rxgain[ir].year,
            shm_addr->rxgain[ir].month,
            shm_addr->rxgain[ir].day);

    logit_nds(output,0,NULL,':');

    /* line 3: date */

    output[start]=0;
    if(shm_addr->rxgain[ir].fwhm.model=='c') {
        strcat(output,"constant,");
        snprintf(output+strlen(output),
                sizeof(output)-strlen(output),
                "%.6f",shm_addr->rxgain[ir].fwhm.coeff*RAD2DEG);
    } else if(shm_addr->rxgain[ir].fwhm.model=='f') {
        strcat(output,"frequency,");
        snprintf(output+strlen(output),
                sizeof(output)-strlen(output),
                "%.6f",shm_addr->rxgain[ir].fwhm.coeff);
    }

    logit_nds(output,0,NULL,':');

    /* line 4: polarizations */

    output[start]=0;
    if(shm_addr->rxgain[ir].pol[0]=='l')
        strcat(output,"lcp");
    else if(shm_addr->rxgain[ir].pol[0]=='r')
        strcat(output,"rcp");

    if(shm_addr->rxgain[ir].pol[1]=='l')
        strcat(output,",lcp");
    else if(shm_addr->rxgain[ir].pol[1]=='r')
        strcat(output,",rcp");

    logit_nds(output,0,NULL,':');

    /* line 5: DPFU */

    output[start]=0;
    snprintf(output+strlen(output),
            sizeof(output)-strlen(output),
            "%.6e",shm_addr->rxgain[ir].dpfu[0]);
    if(shm_addr->rxgain[ir].pol[1]!=0)
        snprintf(output+strlen(output),
                sizeof(output)-strlen(output),
                ",%.6e",shm_addr->rxgain[ir].dpfu[1]);

    logit_nds(output,0,NULL,':');

    /* line 6: gain curve */

    output[start]=0;
    if(shm_addr->rxgain[ir].gain.form=='e')
        strcat(output,"elevation");
    else if(shm_addr->rxgain[ir].pol[0]=='a')
        strcat(output,"altaz");

    strcat(output,",poly");

    iend=shm_addr->rxgain[ir].gain.ncoeff;
    if(iend > 10)
        iend=10;
    for (i=0;i<iend;i++)
        snprintf(output+strlen(output),
                sizeof(output)-strlen(output),
                ",%.6e",shm_addr->rxgain[ir].gain.coeff[i]);

    if(shm_addr->rxgain[ir].gain.opacity=='y')
        strcat(output,",opacity_corrected");

    logit_nds(output,0,NULL,':');

    /* tcal table */

    iend=shm_addr->rxgain[ir].tcal_ntable;
    if(iend > MAX_TCAL)
        iend=MAX_TCAL;
    for (i=0;i<iend;i++) {
        output[start]=0;
        if(shm_addr->rxgain[ir].tcal[i].pol=='l')
            strcat(output,",lcp");
        else if(shm_addr->rxgain[ir].tcal[i].pol=='r')
            strcat(output,",rcp");

        snprintf(output+strlen(output),
                sizeof(output)-strlen(output),
                ",%.6e",shm_addr->rxgain[ir].tcal[i].freq);

        snprintf(output+strlen(output),
                sizeof(output)-strlen(output),
                ",%.6e",shm_addr->rxgain[ir].tcal[i].tcal);

        logit_nds(output,0,NULL,':');
    }

    output[start]=0;
    strcat(output,"end_tcal_table");

    logit_nds(output,0,NULL,':');

    /* trec & spillover */

    output[start]=0;
    if(shm_addr->rxgain[ir].trec[0]>0.0) {
        snprintf(output+strlen(output),
                sizeof(output)-strlen(output),
                "%.6e",shm_addr->rxgain[ir].trec[0]);
        if(shm_addr->rxgain[ir].pol[1]!=0)
            snprintf(output+strlen(output),
                    sizeof(output)-strlen(output),
                    ",%.6e",shm_addr->rxgain[ir].trec[1]);
        logit_nds(output,0,NULL,':');

        iend=shm_addr->rxgain[ir].spill_ntable;
        if(iend > MAX_SPILL)
            iend=MAX_SPILL;
        for (i=0;i<iend;i++) {
            output[start]=0;

            snprintf(output+strlen(output),
                    sizeof(output)-strlen(output),
                    ",%.6e",shm_addr->rxgain[ir].spill[i].el);

            snprintf(output+strlen(output),
                    sizeof(output)-strlen(output),
                    ",%.6e",shm_addr->rxgain[ir].spill[i].tk);

            logit_nds(output,0,NULL,':');
        }
        if(iend>0){
            output[start]=0;
            strcat(output,"end_spillover_table");
            logit_nds(output,0,NULL,':');
        }
    }

    return;
}
void clear_rxgain_files_log()
{
    int i;

    for (i=0;i<MAX_RXGAIN;i++)
        shm_addr->rxgain_files[i].logged=FALSE;

}
