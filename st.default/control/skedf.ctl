*
* skedf.ctl - sked/drudg program control file
*
* Last modified by NRV 951002 for FS9 
*
* This file is free-field except for section names
* which must begin with $ in column 1 and have no
* blanks.  Either upper or lower case is OK for section names.
* Remember path and file names in UNIX are case sensitive.  
*
$catalogs 
*
* Catalog file names: used only by sked.
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
* Enter here the absolute path for writing DRUDG output files,
* e.g. SNAP files. This path is prepended to files written by DRUDG. 
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
* Printer commands: enter printer type for drudg.
* Recognized names: laser, epson, epson24, file. 
*
printer      laser
