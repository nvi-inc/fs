* erchk.ctl -- control file for erchk, error display
*
* Default/Example: /usr2/fs/st.default/control/erchk.ctl
* Working copy:    /usr2/control/erchk.ctl
*
*   Empty lines and lines with an asterisk in column one are ignored
*   as comments. The format is explained after the non-comment lines
*   below.
*
bo  any M  ****
ch  any M  ****
ma  any M  ****
m5  any R  ***
5m  any R  ***
mc  any R  ***
an  any R  ***
fm  any Y  **
* To suppress sp error display (same as pre-10.1.0), remove the 0 on next line.
sp  any 0
any any B  *
*
* Line format:
*
*      code number attributes prefix
*
*   Each non-empty line must have at least the first two tokens and can
*   have the third, and if so, then can have the fourth. There is no
*   fixed limit on the number of lines.
*
*   code       -- 'any' or a two letter FS error code (lower case)
*   number     -- 'any' or a FS error number, usually negative,
*                 a leading '+', if present, will be removed
*   attributes -- Up to two characters for the video attributes (see below)
*                 to use for the error message display.
*                 If missing, this code/number is not displayed.
*   prefix     -- The prefix characters to put in front of the error
*                 message. This can be used to indent error messages to
*                 different levels it make them stand-out. Not required.
*
* When 'erchk' receives a FS error, the handling is based on the
* non-comment lines in this file. The code/number for the error is
* compared to the data on the lines, in order of the lines in the file,
* until a match is found. If 'any' is used for the 'code', it should be
* the last line, since it will match anything regardless of what is used
* for the 'number'. This is a catch-all and must be present for all
* errors to be displayed. Similarly, if 'any' is used for the 'number'
* for a given 'code', it should be the last entry for that 'code', since
* it will match any 'number' for that 'code'. This is a catch-all and
* must be present for any 'code' that has specific 'number's listed in
* order to display all the other messages for that 'code'.
*
* If there are errors in the contents that prevent successful parsing,
* they will all be reported and the program will stop. The 'erchk'
* program can be run by itself, with or without the FS, to test the
* parsing and make corrections as necessary. This does not test whether
* the contents make sense in terms of what is displayed; be careful
* when you make changes.
*
* Video attributes are up to two characters: one letter for the color,
* one number for the emphasis, one letter for the color and one number
* for the emphasis, or two emphasis numbers. The order of two characters
* does not matter. Some combinations, particularly two emphasis numbers,
* may not be useful. Some attributes may not work on some terminals,
* e.g., 'Blink' may only work when the terminal has the focus. Any color
* selection seems to include bold. 'Normal' may remove other attributes.
* Testing on your system is recommended.
*
*  Colors (case sensitive)          Emphasis
*    R   --  Red                       0 -- Normal
*    Y   --  Yellow                    1 -- Bold
*    G   --  Green                     4 -- Underline
*    B   --  Blue                      5 -- Blink
*    M   --  Magenta                   7 -- Inverse
*    C   --  Cyan
*    W   --  White
*    X   --  Black
*
*  Any other characters used as attributes are ignored
