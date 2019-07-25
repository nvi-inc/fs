main(argc, argv)
int argc;
char **argv;
{
    void setup_ids(), go_put();

    setup_ids();
    go_put(argv[1]);

    exit( 0);
}
