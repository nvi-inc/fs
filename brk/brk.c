main(argc, argv)
int argc;
char **argv;
{
    void setup_ids(), brk_snd();

    setup_ids();
    brk_snd(argv[1]);

    exit( 0);
}
