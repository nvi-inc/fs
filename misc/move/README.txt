The 'move' program can be used to reduce mean celestial coordinates
for B1950 or J2000 or apparent coordinates for some epoch to apparent
and topocentric coordinates for an arbitrary date. This uses the same
method as is used by the FS. Accuracy is generally at the 0.1
arcsecond level.

The 'move' program has two modes of operation depending on the number
of command line arguments it has. The modes are:

1. Two arguments.

   This mode takes as the first argument the name of a file with a
   source coordinate list (see 'SOURCE COORDINATE LIST FORMAT' below)
   with either B1950 or J2000 or apparent coordinates of some epoch.
   Note that the effective accuracy of epochs other than B1950 and
   J2000 is limited to about one day.

   The second argument is the target date/time as one spaced delimited
   string with six integer fields. They are: four digit year, day of
   year, hour, minute, second, and centisecond. For example:

     '2021 286 22 51 37 14'

   Note that quoting the string on the command line makes it into a
   single argument, as is required.

   The output is a source list of the apparent coordinates.

2. Three arguments.

   In this mode, the first two arguments are the same as in the two
   argument mode. Additionally, there is a third argument of one space
   delimited string of three floating point fields. They are: west
   longitude (degrees), north latitude (degrees), height above the
   ellipsoid (meters).  For example:

     '159.665 22.126 1140'

   Note that quoting the string on the command line makes it into a
   single argument, as is required.

   The output is a source list of the apparent coordinates followed by
   a source list with topocentric coordinates with local azimuth and
   elevation, not corrected for refraction.

SOURCE COORDINATE LIST FORMAT

The input format is the same as for the 'precess' program. The format
for the input file is a sequence of lines with nine fields:

1. Source name, up to 16 non-blank characters.
2. Right Ascension: integer hours
3. Right Ascension: integer minutes
4. Right Ascension: floating point or integer seconds
5. Declination: sign, must be '+' or '-'
6. Declination: integer degrees
7. Declination: integer minutes
8. Declination: floating point or integer seconds
9. Epoch: floating point or integer. The effective accuracy of epochs
   other than 1950 and 2000 is limited to about one day.

Any trailing fields are ignored.

An example input line:

 3c84       03 16 29.54 + 41 19 51.7 1950

There are example files, ending in '.1950' and '.2000' in the '../precess'
directory.

The output format is very similar, so that with removal of preceding
(and in some cases, following) lines, they can be used as input to the
program. This can be useful for doing the inverse reduction for
verification.

The output format for topocentric coordinates also has local azimuth
and elevation (not corrected for refraction) in degrees added at the
end of the line for each source. These lines can also be used with the
'compare' mode of the 'precess' program because the additional
trailing fields are ignored.
