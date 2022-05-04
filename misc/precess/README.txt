The 'precess' program can be used to precess mean celestial coordinates
between B1950 and J2000. It uses the 'fslb/prefr.f' routine, due
ultimately to Dave Graham. The accuracy is expected to be 0.1 arcseconds
or better.

The 'drudg' program uses the same algorithm, in 'skdrut/prefr.f', to
precess J2000 coordinates to B1950 when making B1950 output for '.snp'
files. The FS 'source=...' command uses 'fslb/' copy to rotate the B1950
coordinates to J2000 before generating topocentric coordinates of date.
The basic idea is that, within the limitations of rounding, FS will get
the same coordinates of date regardless of whether the '.snp' file
contains B1950 or J2000 coordinates.

A separate version of 'precess2' tha uses SOFA routines instead of
'prefr.f' is included. See the end of this file for how to install that.

The 'precess' (or 'precess2') program has three modes. Which is used
depends on the number of command line arguments it has. The modes are:

1. One argument.

   This mode takes as the argument the name of a file with a source
   coordinate list (see 'SOURCE COORDINATE LIST FORMAT' below) with
   either B1950 or J2000 coordinates and rotates it to the other epoch
   and prints the result. This can be useful for translating a list from
   one epoch to the other.

2. Two arguments.

   This mode is similar to the one argument mode, but takes a second
   argument that specifies the name of a second file with a source
   coordinate list. In this mode after the rotation of the first list,
   the result is differenced from the second list and printed. The two
   lists must have the same number of sources, identically named, and in
   the same order. This can be useful to compare a source list at one
   epoch, rotated, to a list at the other.

3. Three arguments.

   In this mode, if the third argument is 'compare'.  The first and
   second source lists are differenced with no rotation applied to
   either. The two lists must have the same number of sources,
   identically named, and in the same order. This can be useful to
   compare two source lists, typically for the same epoch.

SOURCE COORDINATE LIST FORMAT

The input format is the same as for the 'move' program. The format The
format for the input file is a sequence of lines with nine fields:

1. Source name, up to 16 non-blank characters.
2. Right Ascension: integer hours
3. Right Ascension: integer minutes
4. Right Ascension: floating point or integer seconds
5. Declination: sign, must be '+' or '-'
6. Declination: integer degrees
7. Declination: integer minutes
8. Declination: floating point or integer seconds
9. Epoch: floating point or integer, must equal 1950 or 2000 except
   in the three argument 'compare' which can have an arbitrary epoch.

Any trailing fields are ignored.

An example input line:

 3c84       03 16 29.54 + 41 19 51.7 1950

There are example files, ending in '.1950' and '.2000' in this
directory.

The output format is very similar, so that with removal of preceding
(and in some cases, following) lines, they can be used as input to the
program. This can be useful for doing the inverse rotation for
verification.

The output format for differences is slightly different, only because
(i) the R.A. has an additional leading sign field and (ii) the epoch can
be also be positive or negative '50' if different epochs are being
differenced/compared. Differences always have the sign of the second
list minus the first (the latter usually rotated).

PRECESS2

To use SOFA routines, use 'precess2'. The 'sofa' sub-directory must
exist as created by the commands below. To create 'precess2', as
'prog' from the 'misc/precess' (this) sub-directory:

    pushd /tmp
    wget http://www.iausofa.org/2021_0512_F/sofa_f-20210512.tar.gz
    popd
    tar xzf /tmp/sofa_f-20210512.tar.gz
    cd sofa/20210512/f77/src

  Edit 'makefile' adding ' -ff2c' to the end of the 'FX' variable, then:

    make

  You do not need 'make test', then:

    cd ../../../..
    make
