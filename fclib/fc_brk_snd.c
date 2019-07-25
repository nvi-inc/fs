void fc_brk_snd__( prog, lenp)
char *prog;
int lenp;
{
    void brk_snd();

    brk_snd(prog);
}
