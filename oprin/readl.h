struct cmd{
	const char *name;
	void (*cmd)(const char *arg0, const char *arg);
};

char *dupstr(const char *s);
void initialize_readline(const struct cmd* local_commands);
