*
* SKEDF.CTL - SKED program family's control file
*
* Last modified by NRV 901004 for GSFC
*                      950329 adding flux_comments
*
* SKED and DRUDG look for this file in /usr/local/bin/skedf.ctl
* unless you change the default location in the skparm.ftni file and
* re-compile.  SKED and DRUDG also look for skedf.ctl in the local
* directory from which you run the programs.
* If this file is not found, SKED and DRUDG default
* all files and paths as noted below.
*
* This file is free-field except for section names
* which must begin with $ in column 1 and have no
* blanks.  Either upper or lower case is OK for section names.
* Remember path and file names in UNIX are case sensitive.  
*
$catalogs 
*
* Catalog file names:
* Enter here the absolute file name for all catalog files.
* Default catalog names are the same as listed below but
* without the path, e.g. the default source catalog would
* be "source.cat" in the directory from which you are running.
*
*catalog   file name
source     /usr/local/catalogs/source.cat.geodetic
antenna    /usr/local/catalogs/antenna.cat
position   /usr/local/catalogs/position.cat
equip      /usr/local/catalogs/equip.cat
mask       /usr/local/catalogs/mask.cat
sequence   /usr/local/catalogs/sequence.cat
lo         /usr/local/catalogs/lo.cat
head       /usr/local/catalogs/head.cat
hdpos      /usr/local/catalogs/hdpos.cat
tracks     /usr/local/catalogs/tracks.cat
flux       /usr/local/catalogs/flux.cat
comments   /usr/local/catalogs/flux.cat.comments
vlba       /usr/local/catalogs/vlba.cat
*
*
$schedules 
*
* Schedule file path:
* Enter here the absolute path for reading/writing schedules. 
* This path is prepended to schedule files by SKED and DRUDG.
* Default is null, i.e. use your local directory.
*
*
$drudg
*
* DRUDG file path:
* Enter here the absolute path for writing DRUDG output files.
* This path is prepended to files written by DRUDG. 
* Default is null, i.e. use your local directory.
*
*
$scratch 
*
* Scratch directory:
* Enter the absolute path for scratch files. 
* This path is prepended to scratch files by SKED and DRUDG.
* Default is null, i.e. use your local directory.
* All scratch files except the SKED command log are
* deleted upon exiting the programs.
*
/tmp/
*
$print
*
* Printer commands:
* Enter the command strings to be used for printing in portrait or 
* landscape on Laserjet.  The key words "landscape" and "portrait" 
* indicate the orientation.  Following the key word, all characters 
* on the line (including blanks) are read as the command.  For example,
* "portrait lp -onb" would result in using the lp command with no 
* output banner to get output printed. 
* Scripts distributed with SKED include:
* lj   - landscape orientation, line numbers, no banner, small font, date
* ljp  - portrait orientation, otherwise same as lj
* lsk  - landscape orientation, no banner, small font, no line numbers
* lskp - portrait orientation, otherwise same as lsk
* "lsk" and "lskp" are recommended for nice-looking DRUDG output.
*
* type       command
landscape    lpr
portrait     lpr

