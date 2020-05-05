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

/*  This subroutine finds the correct, if only, help file to list */
/*  with the help command. It uses the rack and drive variables   */
/*  passed in by the calling program to match with the extensions */
/*  of the help filenames to find the correct file for listing.   */
/*  The first extension character matches the rack and the second */
/*  the drive. An underscore for an extension character is for    */
/*  any type of equipment. An m is for Mark III, and a v is for   */
/*  VLBA.                                                         */

#include <dirent.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#include "../include/params.h"

#define MAX_STRING 256

// fileexists check if file exists and is readable
static int fileexists(const char *filename) {
	FILE *file;
	if ((file = fopen(filename, "r"))) {
		fclose(file);
		return 1;
	}
	return 0;
}

static char *help_dirs[] = {FS_ROOT "/st/help", FS_ROOT "/fs/help", NULL};

// check_help_dirs looks for file "name" in help dirs and returns first match as a
// string.  Resulting string must be released with free
static char *check_help_dirs(char *name) {
	char **dir;
	char *path;

	for (dir = help_dirs; *dir != NULL; dir++) {
		if (asprintf(&path, "%s/%s", *dir, name) < 0)
			return NULL;
		if (fileexists(path)) {
			return path;
		}
		free(path);
	}
	return NULL;
}

// check_help_dirs_prefix returns a null terminated list of files that start with
// prefix. Returns NULL on error.
// List and its elements must be released by free.
static char **ls_prefix(char **dirs, char *prefix) {

	size_t prefix_len = strlen(prefix);
	if (!prefix_len)
		return NULL;

	// length of allocated buffer
	size_t len = 10;
	char **ret = calloc(len + 1, sizeof(char *));
	if (!ret)
		return NULL;

	DIR *dp;
	struct dirent *ep;

	size_t nmatches = 0;
	char **d;
	for (d = dirs; *d != NULL; d++) {
		dp = opendir(*d);
		if (dp == NULL)
			continue;
		while ((ep = readdir(dp))) {
			if (strncmp(prefix, ep->d_name, prefix_len) != 0) {
				continue;
			}

			nmatches++;

			if (nmatches > len) {
				len += len;
				ret = realloc(ret, (len + 1) * (sizeof(char *)));
				size_t i;
				for (i = len / 2; i <= len; i++) {
					*ret[i] = 0;
				}
			}

			if (asprintf(&ret[nmatches - 1], "%s/%s", *d, ep->d_name) < 0)
				return NULL;
		}
		closedir(dp);
	}
	return ret;
}

void helpstr_(cnam, clength, runstr, rack, drive1, drive2, ierr, clen, rlen)
char *cnam;
int *clength;
char *runstr;
int *rack;
int *drive1;
int *drive2;
int *ierr;
int clen;
int rlen;
{
	char name[MAX_STRING] = {};
	char *decloc;
	char ch1, ch2, ch3;

	*ierr = -3;

	if (*clength > MAX_STRING) {
		*ierr = -2;
		return;
	}

	strncpy(name, cnam, *clength);
	name[*clength] = '\0';

	decloc = strchr(name, '.');
	if (decloc != NULL) {
		char *p = check_help_dirs(name);
		if (p == NULL) {
			return;
		}
		*ierr = 0;
		strcpy(runstr, p);
		free(p);
		return;
	}

	char **paths = ls_prefix(help_dirs, name);
	if (!paths) {
		return;
	}

	char **p;
	for (p = paths; *p != NULL; p++) {
		char *path = *p;
		decloc     = strrchr(path, '.');
		if (decloc == NULL) {
			continue;
		}
		ch1 = *(decloc + 1);
		ch2 = *(decloc + 2);
		ch3 = *(decloc + 3);
		if (
		    (ch1 == '_' ||
		     (ch1 == '3' && K4K3 == *rack) ||
		     (ch1 == 'm' && MK3 == *rack) ||
		     (ch1 == 'n' && (MK3 == *rack || MK4 == *rack || LBA4 == *rack)) ||
		     (ch1 == 'e' && (MK3 == *rack || MK4 == *rack || VLBA == *rack ||
		                     VLBA4 == *rack || LBA4 == *rack || DBBC == *rack)) ||
		     (ch1 == 'f' && (MK3 == *rack || MK4 == *rack || K4K3 == *rack ||
		                     K4MK4 == *rack || K4 == *rack || LBA4 == *rack)) ||
		     (ch1 == '4' && MK4 == *rack) ||
		     (ch1 == 's' && S2 == *rack) ||
		     (ch1 == 'g' && (MK4 == *rack || VLBA == *rack || VLBA4 == *rack ||
		                     K4MK4 == *rack || LBA4 == *rack)) ||
		     (ch1 == 'h' &&
		      (MK4 == *rack || VLBA4 == *rack || K4MK4 == *rack || LBA4 == *rack)) ||
		     (ch1 == 'i' &&
		      (MK4 == *rack || VLBA == *rack || VLBA4 == *rack || K4MK4 == *rack)) ||
		     (ch1 == 'v' && (VLBA == *rack)) ||
		     (ch1 == 'w' && (VLBA == *rack || VLBA4 == *rack)) ||
		     (ch1 == 'k' && (K4K3 == *rack || K4MK4 == *rack || K4 == *rack)) ||
		     (ch1 == 'l' && (LBA == *rack || LBA4 == *rack)) ||
		     (ch1 == 'd' && DBBC == *rack) || (ch1 == 'a' && 0 != *rack)) &&

		    (ch2 == '_' ||
		     ch2 == '+' ||
		     (ch2 == 'k' && K4 == *drive1) ||
		     (ch2 == 'm' && MK3 == *drive1) ||
		     (ch2 == 'n' && (MK3 == *drive1 || MK4 == *drive1)) ||
		     (ch2 == '4' && MK4 == *drive1) || (ch2 == 's' && S2 == *drive1) ||
		     (ch2 == 'w' && (VLBA == *drive1 || VLBA4 == *drive1)) ||
		     (ch2 == 'a' && 0 != *drive1) ||
		     (ch2 == 'l' &&
		      (MK3 == *drive1 || MK4 == *drive1 || VLBA == *drive1 || VLBA4 == *drive1))) &&

		    (ch3 == '_' ||
		     ch3 == '+' ||
		     (ch3 == 'k' && K4 == *drive2) ||
		     (ch3 == 'm' && MK3 == *drive2) ||
		     (ch3 == 'n' && (MK3 == *drive2 || MK4 == *drive2)) ||
		     (ch3 == '4' && MK4 == *drive2) ||
		     (ch3 == 's' && S2 == *drive2) ||
		     (ch3 == 'w' && (VLBA == *drive2 || VLBA4 == *drive2)) ||
		     (ch3 == 'a' && 0 != *drive2) ||
		     (ch3 == 'l' &&
		      (MK3 == *drive2 || MK4 == *drive2 || VLBA == *drive2 || VLBA4 == *drive2))) &&

		    ((*drive1 != 0 && *drive2 != 0 &&
		      ((ch2 == '+' || ch3 == '+') || (ch2 == '_' && ch3 == '_'))) ||
		     ((*drive1 == 0 || *drive2 == 0) && (ch2 != '+' && ch3 != '+')))) {

			strcpy(runstr, path);
			*ierr = 0;
			goto cleanup;
		}
	}

cleanup:

	p = paths;
	while (*p)
		free(*p++);
	free(paths);
}
