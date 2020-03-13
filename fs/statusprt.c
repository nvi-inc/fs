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
/* statusprt.c - print termination status on stderr */

#include <stdio.h>

void statusprt( status)
int status;
{
    int code;
    static char *sigmsg[] = {
        "",
        "Hangup",
        "Interrupt",
        "Quit",
        "Illegal instruction",
        "Trace trap",
        "IOT instruction",
        "EMT instruction",
        "Floating point exception",
        "Kill",
        "Bus error",
        "Segmentation violation",
        "Bad arg to system call",
        "Write on pipe",
        "Alarm clock",
        "Terminate signal",
        "User signal 1",
        "User signal 2",
        "Death of a child",
        "Power fail"
    };
    if ((status & 0377) == 0) {
        if ((code = ((status >> 8) & 0377)) != 0)
            fprintf(stderr,"-Exit code %d",code);
    } else {
        code = status & 0177;
        if (code != 0 && code <= (sizeof(sigmsg)/sizeof(char *)))
            fprintf(stderr,"-%s",sigmsg[code]);
        else
            fprintf(stderr,"-Signal # %d",code);
        if ((status & 0200) == 0200)
            fprintf(stderr,"-core dumped");
    }
}
