*
* skedf.ctl - sked/drudg program control file
*
* This is the default version for drudg in the Field System.
*
* This file is free-field except for section names which must begin
* in column 1 with a $. Either upper or lower case is OK for section
* names. Remember that path and file names in Unix are case-sensitive.
*
$catalogs 
*  not used by drudg
*
$schedules 
* Enter the path name for schedule (.skd) files. If not specified, 
* the default is null, i.e. use the local directory.
* Example: 
*/usr2/prog/
*
$snap
* Enter the path name for SNAP (.snp) files. If not specified, the 
* default is null, i.e. use the local directory.
* Example: 
*/usr2/sched/
*
$proc
* Enter the path name for procedure (.prc) files. If not specified, 
* the default is null, i.e. use the local directory.
* Example:
*/usr2/proc/

$scratch 
* Enter the path name for temporary files. If not specified, the default
* is null, i.e. use the local directory.
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
* Examples:
* This example is for a laser printer, 6 lines/inch, 10 char/inch:
*portrait lpr -ofp10 -olpi6 $*
* This example is the same as above but for landscape:
*landscape lpr -ofp10 -o1pi6 -olandscape $*
* These examples are the same as above but for a smaller font:
*portrait lpr -ofp16.66 -olpi6 $*
*landscape lpr -ofp16.66 -o1pi6 -olandscape $*
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
*
* Tape label printer:
* Enter the name of the label printer. If no name is specified, drudg
* will not attempt to print tape labels. Recognized names are postscript,
* epson, epson24, laser+barcode_cartridge.
* Examples:
*label_printer postscript
*label_printer laser+barcode_cartridge
*label_printer epson
*label_printer epson24
*
* Label size:
* Specify label size parameters, only valid for "postscript" type. If
* no size is specified, drudg cannot print labels.
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
*label_size  1.0   2.625  10     3     0.5   0.3125 Avery 5160
*label_size  1.333 4.0     7     2     0.5   0.25   Avery 5162
*label_size  2.0   4.0     5     2     0.5   0.25   Avery 5163
*label_size  1.5   4.0     6     2     0.75  0.25   Avery 5197
*label_size  1.375 2.75    8     3     0.0   0.0    HP 92285L
*label_size  1.5   3.9     7     2     0.5   0.16   Avery L7163
*
*$misc
* Enter the epoch for drudg to use on the SOURCE commands in SNAP files.
* Default is 1950 if none is specified. Only 1950 or 2000 are valid.
* Examples:
*epoch 2000
*epoch 1950
