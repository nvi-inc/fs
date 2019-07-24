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
            fprintf(stderr,"Signal # %d",code);
        if ((status & 0200) == 0200)
            fprintf(stderr,"-code dumped");
    }
}
