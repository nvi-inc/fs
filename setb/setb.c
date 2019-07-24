main(argc,argv)
int argc;
char **argv;
{
    int iret;

    iret=0;
    while(--argc>0)
     if(-1==chown(*(++argv),0,0)) {
       iret=-1;
       perror(*argv);
     } else if(-1==chmod(*argv,04555)) {
       iret=-1;
       perror(*argv);
     }
     return iret;
}
