/*
 * Copyright (c) 2021 NVI, Inc.
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
#include <stdio.h>
#include <stdlib.h>

#include <string.h>

#include "../include/params.h"

int main(int argc, char **argv)
{
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    int count = 0;

    if(argc < 2) {
        fprintf(stderr,"%s: ",argv[0]);
	fprintf(stderr,"No argument\n");
        exit(EXIT_FAILURE);
    }

    fp = fopen(argv[1], "r");
    if (fp == NULL) {
        fprintf(stderr,"%s: ",argv[0]);
        perror(argv[1]);
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        count++;
        if('*' == line[0])
            continue;
        char *p=strtok(line," \n");
        for (int i=0;i<4;i++)
            p=strtok(NULL," \n");
        if(NULL == p) {
            fprintf(stderr,"%s: ",argv[0]);
            fprintf(stderr,"line %d had no equipment field.\n",count);
            exit(EXIT_FAILURE);
        }
        int rack, drive1, drive2, idum;
        int n=sscanf(p,"%4x%4x%4x%4x",&rack,&drive1,&drive2,&idum);
        if(3!=n) {
            fprintf(stderr,"%s: ",argv[0]);
            fprintf(stderr,"line %d equipment field had %d fields.\n",
                count,n);
            exit(EXIT_FAILURE);
        }
//        printf("%-12s %4x %4x %4x\n",line,rack,drive1,drive2);
        printf("%-12s",line);
        if(0xFFFF == rack) {
            printf(" 0xFFFF\n");
            continue;
        } else if(!rack) {
            printf(" none\n");
            continue;
        }
#define printeq(EQUIP,RACK) { if(EQUIP & RACK) printf(" " #EQUIP);}
          printeq(MK3,rack)
          printeq(VLBA,rack)
          printeq(MK4,rack)
          printeq(S2,rack)
          printeq(VLBA4,rack)
          printeq(K4,rack)
          printeq(K4MK4,rack)
          printeq(K4K3,rack)
          printeq(LBA,rack)
          printeq(LBA4,rack)
          printeq(MK5,rack)
          printeq(DBBC,rack)
          printeq(MK6,rack)
          printeq(RDBE,rack)
          printeq(DBBC3,rack)
        printf("\n");
    }
    if(!feof(fp)) {
        fprintf(stderr,"%s: ",argv[0]);
        perror(argv[1]);
        exit(EXIT_FAILURE);
    }

    fclose(fp);
    if (line)
        free(line);

    exit(EXIT_SUCCESS);
}
