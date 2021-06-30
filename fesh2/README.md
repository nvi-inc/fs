# Fesh2: Geodetic VLBI schedule file management and processing

## What is it?
**Fesh2** is a Python package that provides automated schedule file
 preparation. It requires an installation of the [NASA Field System](https://github.com/nvi-inc/fs). 

**Fesh2** runs in a
terminal window and regularly checks IVS schedule repositories for new or updated 
versions of Master files and schedule files for one or more specified stations. 
A check for the latest version of the Master file(s) is done first, but skipped if the time since the last check is less than a
specified amount (configurable on the command line or in the config file). 
Similarly, checks on schedule files are only done if the time since the
last check exceeds a specified time. Checks can be forced on the command line.
If new or updated schedules are found, they are optionally processed with **Drudg** 
to produce `snp`, `prc` and `lst` files. By default, once the files have been
checked, **fesh2** will provide a summary and then go into a wait
state before carrying out another check. **Fesh2** can also be run once for a 
single check and not go into a wait state.

## Compatibility
  * **Fesh2** has been tested for the following Python versions:
    * 2.7.16
    * 3.7.3
    * 3.8.2

## Installation
Installation should probably be carried out from the superuser account

```
cd /usr2/fs/fesh2/fesh2
python setup.py install
```
You will then need to edit the **fesh2** configuration file for your station(s). 
More information is provided below in the Configuration section.

## Configuration
**Fesh2** looks for a configuration file in `/usr2/control` called `fesh2.config`. 
*This will need to be set up for your station before running **fesh2** for
 the first time.* Use
 your favourite text editor to modify the file. The comments in the file
  describe the parameters but here are a few points to note:
### Station settings
You will want to edit options in the `[Station]` section to configure which
stations you want to process, what types of Master and schedule files you
want to obtain, how far into the future you want to search for schedule
files and how often you want to look for them.

### Servers
The `[Servers]` section allows you to list all the IVS schedule file servers
you want to search and the protocols to use for each. Specify the location
of the top directory (i.e. the `vlbi` directory). Protocols known to work are
https (secure HTTP), ftp (anonymous FTP) and ftps (secure (SSL) anonymous FTP).
    
### Curl
**Fesh2** uses [curl](http://pycurl.io/docs/latest/index.html) to access files 
on the servers. If https is being used
 (e.g. to access the CDDIS repository), then **fesh2** needs to know the
  location of your `.netrc` and `.urs_cookies` files. If you  don't  intend to use  https then place empty files in these locations. 

### Drudg
After finding and downloading a new or updated schedule, Fesh2 can optionally run Drudg to produce
 new snp, prc and lst files. The `[Drudg]` section allows you to configure
  this behaviour. If you don't want **fesh2** to automatically process your
   schedules (it will overwrite old files), this feature con be turned off be
    setting `do_drudg` to `False`.

## Usage
In many cases, **Fesh2** can be started by just typing
```
fesh2
```
which starts it in its default mode. However command-line options exist to
 change many of the configuration parameters, allow for a one-off checks
  (no wait mode), forcing of file downloads etc. Command-line parameters are
   as follows:  

```
usage: fesh2 [-h] [-c CONFIG] [-g GET] [-t TMASTER] [-s TSCHED] [-m] [-u] [-d]
             [-n] [-a] [-o] [-l LOOKAHEAD] [-y YEAR]
             [stns [stns ...]]

positional arguments:
  stns                  Stations to consider (default "hb ke yg ho")

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIG, --config CONFIG
                        The configuration file to use. (default is
                        /usr2/control/fesh2.config)
  -g GET, --get GET     Just get a schedule for this specified session. Give
                        the name of the session (e.g. r4951).
  -t TMASTER, --tmaster TMASTER
                        Only check for a new master file if the last check was
                        more than this number of hours ago. The default is set
                        in the configuration file.
  -s TSCHED, --tsched TSCHED
                        Only check for a new schedule file (SKD or VEX) if the
                        last check was more than this number of hours ago. The
                        default is set in the configuration file.
  -m, --master-update   Force a download of the Master Schedule (default =
                        False).
  -u, --sched-update    Force a download of the Schedules (default = False).
  -d, --no-drudg        Force NOT to run Drudg on the downloaded/updated
                        schedules (default = False)
  -n, --current, --now  Only process the current or next experiment
  -a, --all             find the experiments with all "stns" in it
  -o, --once            Just run once then exit, don't go into a wait loop
                        (default = False)
  -l LOOKAHEAD, --lookahead LOOKAHEAD
                        only look for schedules less than this number of days
                        away
  -y YEAR, --year YEAR  The year of the Master Schedule (default is the
                        current year)
```

## Logging
As well as writing information to the screen on activity, **fesh2** also
 keeps a log of activity in the Field System log directory at `/usr2/log
 /fesh2.log`. 
