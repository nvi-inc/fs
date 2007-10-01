***********************************************************************
* skedf.ctl - sked/drudg program control file
*
* This is the default version for drudg in the Field System.
*
* This file is free-field except for section names which must begin
* in column 1 with a $. Either upper or lower case is OK for section
* names. Remember that path and file names in Unix are case-sensitive.
* Some sections are used by sked, some by drudg, and some by both.
* Edit or un-comment the lines that you need.
*
* sked and drudg read two versions of this file. The first version is
* the system control file which is read from a path specified at
* compile time. The second version is read from the user's local area.
* Any items in the local area control file override those in the
* system control file.
***********************************************************************
*
$catalogs 
* Note: The $catalogs section is used by sked but not by drudg.
*
$schedules 
* Enter the path name for schedule (.skd) files. If not specified, 
* the default is null, i.e. use the local directory. Both sked and
* drudg look for schedules in this path.
* Example: 
*/usr2/prog/
*
$snap
* Enter the path name for reading or writing SNAP (.snp) files. If 
* not specified, the default is null, i.e. use the local directory.
* This is used by drudg.
* Example: 
*/usr2/sched/
*
$proc
* Enter the path name for writing procedure (.prc) files. If not specified, 
* the default is null, i.e. use the local directory.
* This is used by drudg.
* Example:
*/usr2/proc/

$scratch 
* Enter the path name for temporary files. If not specified, the default
* is null, i.e. the files will be written into the local directory.
* This is used by both sked and drudg.
/tmp/
*
$print
* Printer type:
* Enter the printer type for drudg. If not specified, default is laser.
* Recognized names: laser, epson, epson24.
* This can be changed interactively with option 9.
* Examples:
* printer laser
* printer epson
* printer epson24
*
* Printer type:
* Enter any command strings or scripts to be used for printing in 
* portrait or landscape. The key words "landscape" and "portrait" 
* indicate the orientation.  Following the key word, all characters 
* on the line (including blanks) are read as the command.
* If no commands or scripts are specified, drudg defaults to embedding
* escape sequences for the output desired into the file and uses
* the system command "recode latin1:ibmpc" piped to "lpr" to print
* the temporary file.
* This example is for a laser printer, 6 lines/inch, 10 char/inch:
*  portrait lpr -ofp10 -olpi6 $*
* This example is the same as above but for landscape:
*  landscape lpr -ofp10 -olpi6 -olandscape $*
* The above two examples correspond to portrait and landscape large font.
* These examples are the same as above but for a smaller font:
* 16.66 char/inch, 8 lines/inch
* portrait lpr -ofp16.66 -olpi8 $*
* landscape lpr -ofp16.66 -olpi8 -olandscape $*
*portrait <script name for portrait output>
*landscape <script name for landscape output>
*
* Output control:
* Enter the desired orientation and font size for listings. Key words
* are option1, option4, and option5 for the three listing options.
* Follow the key word by a 2-letter code, first letter "p" or "l" for
* portrait or landscape, second letter "s" or "l" for small or large
* font. If none are specified, the defaults are as listed below:
*option1 ls (landscape, small font)
*option4 ps (portrait, small font)
*option5 ps (portrait, small font)
*
* Tape label script:
* Enter a script for printing tape labels. If no script is specified,
* the default is to use "lpr" to print the temporary file.
* Examples:
*labels <script name for label printing>
*labels print2dymo
*  This is to print to the dymo printer.
*  Script "print2dymo" must be
*    1.) In your path, e.g. in /usr2/oper/bin,
*    2.) Executable, e.g., chmod a+x print2dymo
*  This script has lines apropriate for FS Linux 5 and FS Linux 6.
*
* Tape label printer:
* Enter the name of the label printer. If no name is specified, drudg
* will not attempt to print tape labels. Recognized names are postscript,
* epson, epson24, laser+barcode_cartridge.
* Examples:
*label_printer dymo
*label_printer postscript
*label_printer laser+barcode_cartridge
*label_printer epson
*label_printer epson24
*
* Label size:
* Specify label size parameters, only valid for "postscript" type.
* If no size is specified, drudg assumes Avery 5160. 
* The option that has the largest product of <rows>*<cols> is a good choice
* if you are just printing to plain paper, for example Avery 5160 prints 30
* labels per page.
* <ht> height of a single label, in inches
* <wid> width of a single label, in inches
* <rows> number of rows of labels on the page
* <cols> number of columns of labels on the page
* <top> offset of the top edge of the first row of labels from the 
*      top of the page, in inches
* <left> the offset of the left edge of the first column of labels
*      from the left side of the page, in inches
* Format:
* label_size <ht> <wid> <rows> <cols> <top> <left>
* Examples:
*label_size   1.417 3.5     1     1    0.0   0.0    Dymo
*label_size  1.0   2.625  10     3     0.5   0.3125 Avery 5160
*label_size  1.333 4.0     7     2     0.5   0.25   Avery 5162
*label_size  2.0   4.0     5     2     0.5   0.25   Avery 5163
*label_size  1.5   4.0     6     2     0.75  0.25   Avery 5197
*label_size  1.375 2.75    8     3     0.0   0.0    HP 92285L
*label_size  1.5   3.9     7     2     0.5   0.16   Avery L7163
*
$misc
*This is for dealing with Mark5 data transfer issues.
*Default directory for the disk2file command.
*Note shell expansions like "~" will not work, use absolute pathnames,
*     relative pathnames may work if you are careful about the working
*     directory of the Mark5A program.
*EXAMPLE
* disk2file_Dir /r1234/data
* Sets up AutoFTP
*EXAMPLE
* AutoFTP ON arbitrary_string_with_out_spaces 
*
* Epoch:
* Enter the epoch for drudg to use on the SOURCE commands in SNAP files.
* Default is 1950 if none is specified. Only 1950 or 2000 are valid.
* Examples:
*epoch 2000
*epoch 1950
*
* Station equipment:
* Station equipment may be specified in drudg. Equipment names are 
* case sensitive. Allowed rack and recorder names are: 
*
* Station equipment:
* Station equipment may be specified in drudg or in the equip line below.
*  Equipment names are NOT case sensitive.
*  Allowed rack and recorder names are:
*  Racks   |  Recorders
*  --------+-----------
*  none    |  none
*  Mark3A  |  unused
*  VLBA    |  Mark3A
*  VLBAG   | VLBA
*  VLBA/8  | VLBA4
*  VLBA4/8 | Mark4
*  Mark4   | S2
*  VLBA4   | K4-1
*  K4-1    | K4-2
*  K4-2    | Mark5A
*  K4-1/K3 | Mk5APigW
*  K4-2/K3 | Mark5P
*  K4-1/M4 | K5
*  K4-2/M4 | Mark5B
*  LBA     | unknown
*  Mark5   |
*  VLBA5   |
*  unknown |
*
* Relationship between skedf.ctl and equip.ctl file names:
*
*   skedf.ctl        equip.ctl
*   (and VEX files)
*   ---------------  --------------------------------------
*   Mark3A           mk3 mk3b
*   VLBA             vlba vlbag 
*   VLBA/8           vlba vlbag   (8 BBCs only)
*   VLBA4/8          vlba4        (8 BBCs only)
*   Mark4            mk4
*   VLBA4            vlba4
*   K4-1/K3          k41 k41u k41/k3 k41u/k3
*   K4-2/K3          k42 k42a k42bu k42/k3 k42a/k3 k42bu/k3
*   K4-1/M4          k41 k41u k41/m4 k41u/m4
*   K4-2/M4          k42 k42a k42bu k42/m4 k42a/m4 k42bu/m4
*   K4-1             k41 k41/dms
*   K4-2             k42 k42/dms
*   S2               s2
*   LBA              lba
*
* If the schedule file does not have equipment specified, then the 
* equipment in the control file will be used.
* A warning message is issued if the control file and schedule file
* equipment are different.
* Format:
* equipment <rack> <recorder A> <recorder B>
* Examples:
* equipment Mark4  Mark5A  none
* equipment VLBA   VLBA  VLBA
*
* If equipment_override is specified (uncommented below) then the
* equipment in the control file is used. This then becomes your default
* equipment regardless of what is in the schedule. This is a useful way of 
* forcing the recorder to be Mark5A during the transition from tape to disk.
*  equipment_override 
*--------------------------------------------------------------
* TPI daemon setup
*   prompt? 
*     NO:  Default. Never prompt, use the specified period for all schedules
*     YES: Prompt for the period for all schedules and use the period 
*     specified as the default
*   period 
*     <value>: specify the TPI sampling period in centiseconds, 0=off,
*              default is 0.
* 
* examples:
*       prompt? period 
* tpicd  NO       0    <<<<<<< don't use the TPI daemon (default values)
* tpicd  NO      100   <<<<<<< always use 1 sec period
* tpicd  YES      0    <<<<<<< prompt for period, default is OFF
* tpicd  YES     500   <<<<<<< prompt for period, default is 5 sec
*--------------------------------------------------------------
