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
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#define LEN(X) sizeof(X) / sizeof(*X)

#include "../server.c"

#include "convey.h"

char *args[] = {"zero", "one", "two", "three"};

char *xargs_full[]       = {"-x", "xarg", "-y", "yarg", "-e", "eargs1", "eargs2"};
char *xargs_no_e[]       = {"-x", "xarg", "-y", "yarg", "eargs1", "eargs2"};
char *xargs_e_at_start[] = {"-e", "eargs1", "eargs2"};
char *xargs_e_at_end[]   = {"args1", "args2", "-e"};

Main({
	Test("utilitys", {
		Convey("strjoin works", {
			char *s;
			Convey("empty arguments return NULL", {
				s = strjoin(0, args);
				So(s == NULL);
			});
			Convey("one strings works", {
				s = strjoin(1, args);
				So(strcmp(s, "zero") == 0);
			});

			Convey("two string works", {
				s = strjoin(2, args);
				So(strcmp(s, "zero one") == 0);
			});

			Convey("four string works", {
				s = strjoin(4, args);
				So(strcmp(s, "zero one two three") == 0);
			});
			if (s != NULL)
				free(s);
		});

		Convey("args_split works", {
			char *left;
			char *right;
			int ret;
			Convey("full args works", {
				args_split(LEN(xargs_full), xargs_full, "-e", &left, &right);
				So(ret >= 0);
				So(strcmp(left, "-x xarg -y yarg") == 0);
				So(strcmp(right, "eargs1 eargs2") == 0);
			});
			Convey("error returned correcly on missing sep", {
				int ret =
				    args_split(LEN(xargs_no_e), xargs_no_e, "-e", &left, &right);
				So(ret == -1);
			});

			Convey("empty left if sep at start", {
				args_split(LEN(xargs_e_at_start), xargs_e_at_start, "-e", &left,
				           &right);
				So(ret == 0);
				So(left == NULL);
				So(strcmp(right, "eargs1 eargs2") == 0);
			});

			Convey("empty right if sep at end", {
				args_split(LEN(xargs_e_at_end), xargs_e_at_end, "-e", &left,
				           &right);
				So(ret == 0);
				So(right == NULL);
				So(strcmp(left, "args1 args2") == 0);
			});
			if (right != NULL)
				free(right);
			if (left != NULL)
				free(right);
		});

		Convey("parse x window geometry works", {
			struct winsize *w;

			Convey("empty arguments handled", {
				parse_xargs_to_winsz(NULL, &w);
				So(w == NULL);

				parse_xargs_to_winsz("", &w);
				So(w == NULL);
			});

			Convey("invalid arguments handled", {
				parse_xargs_to_winsz("xterm -geometry dog", &w);
				So(w == NULL);

				parse_xargs_to_winsz("xterm -geometry cow+horse", &w);
				So(w == NULL);

				parse_xargs_to_winsz("xterm -geometry cowxhorse", &w);
				So(w == NULL);

				parse_xargs_to_winsz("xterm -geometry x100-100", &w);
				So(w == NULL);

				parse_xargs_to_winsz("xterm -geometry 100x", &w);
				So(w == NULL);
			});

			Convey("valid arguments handled", {
				parse_xargs_to_winsz("xterm -geometry 10x20", &w);
				So(w->ws_col == 10 && w->ws_row == 20);
				free(w);

				parse_xargs_to_winsz("xterm -geometry 1x2+100-100", &w);
				So(w->ws_col == 1 && w->ws_row == 2);
				free(w);

				parse_xargs_to_winsz("xterm -geometry +100-100", &w);
				So(w == NULL);
			});
		})
	});
});
