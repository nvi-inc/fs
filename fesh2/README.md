# Fesh2: Geodetic VLBI schedule file management and processing

## What is it?

**Fesh2** is a Python package that provides automated schedule file preparation.
It requires an installation of the
[NASA Field System](https://github.com/nvi-inc/fs).

**Fesh2** runs in a terminal window and regularly checks IVS schedule
repositories for new or updated versions of Master files and schedule files for
one or more specified stations. A check for the latest version of the Master
file(s) is done first, but skipped if the time since the last check is less than
a specified amount.
Similarly, checks on schedule files are only done if the time since the last
check exceeds a specified time. If new or updated schedules are found, they are
optionally processed with **Drudg**
to produce `snp`, `prc` and `lst` files. By default, once the files have been
checked, **fesh2** will provide a summary and then go into a wait state before
carrying out another check. **Fesh2** can also be run once for a single 
check or
status report and not go into a wait state. **Fesh2** can also be run 
in a `monit` mode that gives a continually updating status report but 
does not process any files. Multiple 
instances can be run
simultaneously. If drudg output (`snp` or `prc
` files) have been modified by the user and a new schedule becomes available
, **fesh2** will download the file but not overwrite Drudg output, but it will
warn the user.

**Fesh2** can be run as a foreground application or as a service in the
background.

## Compatibility

**Fesh2** code is compatible with Python versions 3.5 and above has been 
tested under version 3.7.3

***Note that **fesh2** is not compatible with Python version 2.***

## Installation

**Fesh2** is distributed as part of the
[Field System](https://github.com/nvi-inc/fs) however, it is not installed 
as part of 
the standard procedure and must be done as a separate step. 

### PycURL dependency

Fesh2 depends on the python CURL
library ([PycURL](http://pycurl.io/docs/latest/index.html))
which should be installed automatically when you install fesh2. However, PycURL
depends on the Python development libraries, and it won't install if they're not
there. On a Debian machine, 

    apt-get install python3-dev

should do the trick. You may also need these: 

    apt-get install libcurl4-openssl-dev libssl-dev

### Fesh2 installation

Assumes that python libraries and executables will be kept in /usr2/fs/python
Makefile will install fesh2 unless the FS_FESH2_NO_MAKE environment variable is set.

IF so, PYTHONPATH needs setting up as follows 
    export PYTHONPATH=$PYTHONPATH:/usr2/fs/python
And /usr2/fs/python/bin needs added to the PATH.
    export PATH=$PATH:/usr2/fs/python/bin
Running Make will execute this:
    python setup.py install --home=/usr2/fs/python

We are cleared to use pip. (Whew!) So I think we can proceed under that approach and prog could install it. I will try to look it later this week. In the meantime, there are some questions/comments below.

It seems like symlinking from bin/ should work, but maybe I am missing something.

Unless fesh2 will work all the way back to Lenny, we will need building it to be optional (and maybe there other systems where it wouldn't work). This could be accomplished with an environment variable that would have to be set for the top-level Makefile. We can add the environment variable at the last minute and just work from a Makefile in fesh2/ for now. Maybe some one has a better idea.

Of course, it would be helpful if it worked as far back as Lenny. If that is possible and not unreasonable amount of work, that would be good. If it is possible but too much work, it would have to be deferred (maybe until we no longer support Lenny :).

If it is installed as part of the FS, I wonder how fesh2 as a service will interact with re-making the FS. The .o and executables may be deleted and remade from time-to-time. Will that cause a problem? If that gets too awkward., it may be better to have it as a separate application.

There are other details that will need to be ironed out.

BTW, BKG is changing to ftp-ssl as the only access method. We should start with ftp-ssl as the default for them. They already have it working. They plan to go to individual user accounts soon. So it would good if fesh2 supports that too. There is some talk that they will go to https eventually. If that can be allowed for as well, it would probably be a good idea.


Installation should be carried out under the
`prog` account. You may wish to install fesh2 within a python virtual 
environment, but regardless, the installation commands are the same:

Fesh2 is distributed as part of the Field System and can be found in 
   '/usr2/fs/fesh2'. There are two installation options. 
#### Installing from the distributed code:
Run the following:
   ```
   cd /usr2/fs/fesh2
   python3 setup.py install
   ```
#### Installing with pip:
Run the following:
   ```
   cd /usr2/fs/fesh2
   pip3 install -v --upgrade  dist/fesh2-2.3.0.tar.gz
   ```

Watch out for WARNING messages. In some Field System setups it may not be 
possible for the prog account to write to the /usr2/control directior, in 
which case the default configuration file needs copying there manually. A 
warning message is issued if this is the case. 

You will then need to edit the **fesh2** configuration file for your station
(s). More information on configuration is provided below.

A template configuration file is provided in fs/st.default/fesh2.config. 
This should be placed in /usr2/control and edited to suit your site.



## Configuration

**Fesh2** will take its configuration in the following priority order from
lowest to highest:

* Two config files, in this order:
    * `/usr2/control/skedf.ctl`
    * `/usr2/control/fesh2.config`
* Environment variables
* Command-line parameters

Note that Fesh2 will only run Drudg if it DoDrudg is set to True and it is
configured appropriately. See the Drudg notes below.

If you have the configuration files in a different location to `/usr2/control`,
use the command-line options `--ConfigFile` and `--SkedConfigFile` to set them
appropriately.

### Environment Variables

The following environment variables are recognised by **fesh2**:

* `NETRC_FILE` and `COOKIES_FILE`: the locations of the `.netrc` and
  `.urs_cookies
  ` files, used by CURL for the https protocol. Curl sets these to files in the
  home directory by default. More information is given below on Curl
  configuration.
* `LIST_DIR` : the directory where **drudg** puts `.lst` output files. If this
  is not set, then the `LstDir` parameter in `fesh2.config` is used if set.
  Otherwise **drudg** defaults to the `$schedules` parameter in `skedf.ctl`

A number of environment variables used by **drudg** are also recognised by 
**fesh2**. See the **drudg** section below.  The 
following 
environment variables are _NOT_ recognised by **fesh2**:

* `STATION` is used in the Field System but not recognised by **fesh2** as it is
  possible to configure **fesh2** to manage schedules for multiple stations .
  The `Stations` parameter _must_ be set in `fesh2.config`

### The fesh2 configuration file

On startup, **fesh2** looks for a configuration file called `fesh2.config`. 
*This will need to be set up for your station before running **fesh2** for the
first time.* Use your favourite text editor to modify the file. The comments in
the file describe the parameters but here are a few points to note:

#### Station settings

You will want to edit options in the `[Station]` section to configure which
stations you want to process, what types of Master and schedule files you want
to obtain, how far into the future you want to search for schedule files and how
often you want to look for them.

#### Email

If enabled, notification can be sent via email when:

* a new schedule has been downloaded
* a schedule file has been updated on the server, downloaded and needs manual
  processing

#### Drudg

After finding and downloading a new or updated schedule, **Fesh2** can
optionally run **Drudg** to produce new snp, prc and lst files. The `[Drudg]`
section allows you to configure this behaviour. If you don't want **fesh2** to
automatically process your schedules, this feature con be turned off by
setting `DodDrudg` to `False`.

Because **fesh2** manages schedule files and uses **drudg** to process them, and
to keep things consistent across the Field System, it will use settings
in `skedf.ctl`. However, there are some caveats regarding `skedf.ctl` for the
case where there is not an overriding definition:

* **Fesh2** requires that `$schedules` is defined in `skedf.ctl`. The default
  of '.' (i.e. the directory the software is started in) is too arbitrary and
  could cause **fesh2** to lose track of files.
* If `$snap` or `$proc` are not defined, then they will be set to the same as
  `$schedules`

Drudg may have been configured such that the user is prompted for a response, in
which case it cannot be automated. If this is the case, then Drudg will not be
run on SKD files.

If you want Fesh2 to automatically process SKD files, then some configuration is required. Fesh2 will get it's configuration information as follows, in
this priority order (lowest to highest):

1. Fesh2 will first look in `/usr2/control/skedf.ctl`. Unless parameters are
   changed, Fesh2 will not run Drudg if the following parameters are set as
   shown:
    * `tpicd YES`
    * `vsi_align ASK`
    * `cont_cal ASK`
    * `cont_cal_polarity ASK`

2. Fesh2 will then look for any configuration parameters in the `[Drudg]`
   secoion of `fesh2.config`. These parameters can be different to `skedf.ctl`
   in case you want Drudg to behave differently when Fesh2 is running it for you

3. There are some `FESH` environment variables which can be set and these will
   override skedf.ctl or this file if they are. These environment variables are
   as follows with the lowest supported version of Drudge shown in brackets (text from FS documentation):
    * `FESH_GEO_TPICD` *(10.0.0-beta3, December 2020)* Possible values are
      non-negative integers. If set, the value is provided as the answer for the
      drudg prompt for the tpicd interval for geodesy schedules.
    * `FESH_GEO_CONT_CAL` *(10.0.0-beta3, December 2020)* Possible values
      are `on` or `off`. If set, the value is provided as the answer for the
      drudg prompt for continuous cal use for geodesy schedules.
    * `FESH_GEO_CONT_CAL_POLARITY` *(10.0.0-beta3, December 2020)* Possible
      values are `0`, `1`, `2`, `3,` or `none`. If set, the value is provided as
      the answer for the drudg prompt for the continuous cal polarity for
      geodesy schedules.
    * `FESH_GEO_VSI_ALIGN` *(10.0.0-beta3, December 2020)* Possible values
      are `0`, `1`, or `none`. If set, the value is provided as the answer for
      the drudg prompt for using vsi_align for geodesy schedules.
    * `FESH_GEO_USE_SETUP_PROC` *(10.1.0, 2021)* Possible values are `yes`
      or `no`. If set, the value is provided as the answer for the drudg prompt
      for the *"use setup_proc"* for geodesy schedules, an option to write
      a `.snp` file that skips setup on scans when the mode hasn’t changed.
    * `FESH_GEO_VDIF_SINGLE_THREAD_PER_FILE` *(10.1.0, 2021)* Possible values
      are `yes` or `no`. If set, the value is provided as the answer for the
      drudg prompt for the *"VDIF single thread per file"* for geodesy
      schedules.

4. Lastly, if any Drudg-related command-line parameters are set, they will
   override everything else

*If any Drudg settings recieved by Fesh2 require manual intervention, Drudg will
not be run on the SKD files.*

#### Servers

The `[Servers]` section allows you to list all the IVS schedule file servers you
want to search and the protocols to use for each. Specify the location of the
top directory (i.e. the `vlbi` directory). Protocols known to work are https (
secure HTTP), ftp (anonymous FTP) and ftps (secure (SSL) anonymous FTP).

#### Curl

**Fesh2** uses [curl](http://pycurl.io/docs/latest/index.html) to access files
on the servers. If https is being used
(e.g. to access the CDDIS repository), then **fesh2** needs to know the location
of your `.netrc` and (
optionally) `.urs_cookies` files. Curl puts these in the user's home directory
by default but they can be placed elsewhere if desired. This can be set on the
command line or via the NETRC_FILE and COOKIES_FILE environment variables (
see above
) or in the **fesh2** config file by setting the NetrcFile and CookiesFile
parameters.

## Usage

**Fesh2** can be started by just typing
```
fesh2
```

which starts it in its default mode. **fesh2** can also be run in monitoring 
mode in a terminal window by typing:
```
fesh2 --monit
```
*Note: If you run **fesh2** as multiple instances but with different 
configuration (e.g. running it in the background with SnapDir set on the 
command line, then running it as a monitor with the default SNAP file 
directory) then you may see some unexpected behaviour. In the above 
example, a schedule could be generated by drudg in the non-default SNAP 
directory but ```fesh2 --monit``` would think that the schedule hadn't 
been processed.*

Command-line options exist to change many of the configuration parameters, allow
for a one-off checks
(no wait mode), forcing of file downloads etc. Some common usages are:

* Only consider the current or next experiment
```
fesh2 -n
```
* Just run once then exit, don't go into a wait loop
```
fesh2 --once
```
* Just get a schedule for a specified session, then exit. e.g.:
```
fesh2 --once -g r1456
```
* Force an update to the schedule file when there's a new one available to
  replace the old one. The default behaviour is to give the new file the name
  ```<code>.skd.new``` and prompt the user to take action. The file will also be
  drudged if the DoDrudg option is True
```
fesh2 --update
```
* Obtain schedule files, but don't process them:
```
fesh2 --DoDrudg False
```
* Get a status report. Shows the status of schedule files and when schedule
  servers were last queried.
```
fesh2 --check
```
* Run fesh2 with all terminal output suppressed. Useful when running fesh2 as a
  service.
```
fesh2 --quiet
```
All command-line parameters are as follows:
```
usage:       fesh2 [-h] [-c CONFIGFILE] [-k SKEDCONFIGFILE] [-g GET] [-m] [-u]
                   [-n] [-a] [-o] [--update] [--SchedDir SCHEDDIR]
                   [--ProcDir PROCDIR] [--SnapDir SNAPDIR] [--LstDir LSTDIR]
                   [--LogDir LOGDIR] [--Stations [STATIONS [STATIONS ...]]]
                   [--EmailNotifications [EMAILNOTIFICATIONS]]
                   [--GetMaster [GETMASTER]]
                   [--GetMasterIntensive [GETMASTERINTENSIVE]]
                   [--SchedTypes [SCHEDTYPES [SCHEDTYPES ...]]]
                   [-t MASTERCHECKTIME] [-s SCHEDULECHECKTIME]
                   [-l LOOKAHEADTIMEDAYS] [-d [DODRUDG]]
                   [--DrudgBinary DRUDGBINARY] [--TpiPeriod TPIPERIOD]
                   [--VsiAlign VSIALIGN] [--ContCalAction CONTCALACTION]
                   [--ContCalPolarity CONTCALPOLARITY] [--SetupProc SETUPPROC]
                   [--VdifSingleThreadPerFile VDIFSINGLETHREADPERFILE]
                   [--Servers [SERVERS [SERVERS ...]]] [--NetrcFile NETRCFILE]
                   [--CookiesFile COOKIESFILE]
                   [--CurlSecLevel1 [CURLSECLEVEL1]] [-y YEAR] [-e] [--monit]
                   [-q]

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIGFILE, --ConfigFile CONFIGFILE
                        The fesh2 configuration file to use. e.g.
                        /usr2/control/fesh2.config
  -k SKEDCONFIGFILE, --SkedConfigFile SKEDCONFIGFILE
                        The location of the skedf.cfg configuration file
  -g GET, --get GET     Just get a schedule for this specified session. Give
                        the name of the session (e.g. r4951).
  -m, --master-update   Force a download of the Master Schedule (default =
                        False), but just on the first check cycle.
  -u, --sched-update    Force a download of the Schedules (default = False),
                        but just on the first check cycle.
  -n, --current, --now  Only process the current or next experiment
  -a, --all             Find the experiments with all "Stations" in it
  -o, --once            Just run once then exit, don't go into a wait loop
                        (default = False)
  --update              Force an update to the schedule file when there's a
                        new one available to replace the old one. The default
                        behaviour is to give the new file the name
                        <code>.skd.new and prompt the user to take action. The
                        file will also be drudged if the DoDrudg option is
                        True
  --SchedDir SCHEDDIR   Schedule file directory
  --ProcDir PROCDIR     Procedure (PRC) file directory
  --SnapDir SNAPDIR     SNAP file directory
  --LstDir LSTDIR       LST file directory [env var: LIST_DIR]
  --LogDir LOGDIR       Log file directory
  --Stations [STATIONS [STATIONS ...]]
                        Stations to consider (e.g. "hb ke yg ho", "mg")
  --EmailNotifications [EMAILNOTIFICATIONS]
                        Send notifications by email. The fesh2 config file
                        will be read for details on mail server, recipients
                        etc
  --GetMaster [GETMASTER]
                        Maintain a local copy of the main Multi-Agency
                        schedule, i.e. mostly 24h sessions (default = True)
  --GetMasterIntensive [GETMASTERINTENSIVE]
                        Maintain a local copy of the main Multi-Agency
                        Intensive schedule (default = True)
  --SchedTypes [SCHEDTYPES [SCHEDTYPES ...]]
                        Schedule file formats to be obtained? This is a
                        prioritised list with the highest priority first. Use
                        the file name suffix ("vex" and/or "skd") and comma-
                        separated.
  -t MASTERCHECKTIME, --MasterCheckTime MASTERCHECKTIME
                        Only check for a new master file if the last check was
                        more than this number of hours ago. The default is set
                        in the configuration file.
  -s SCHEDULECHECKTIME, --ScheduleCheckTime SCHEDULECHECKTIME
                        Only check for a new schedule file (SKD or VEX) if the
                        last check was more than this number of hours ago. The
                        default is set in the configuration file.
  -l LOOKAHEADTIMEDAYS, --LookAheadTimeDays LOOKAHEADTIMEDAYS
                        Only look for schedules less than this number of days
                        away (default is 7)
  -d [DODRUDG], --DoDrudg [DODRUDG]
                        Run Drudg on the downloaded/updated schedules (default
                        = True)
  --DrudgBinary DRUDGBINARY
                        Location of Drudg executable (default =
                        /usr2/fs/bin/drudg)
  --TpiPeriod TPIPERIOD
                        Drudg config: TPI period in centiseconds. 0 = don't
                        use the TPI daemon (default) [env var: FESH_GEO_TPICD]
  --VsiAlign VSIALIGN   Drudg config: Applicable only for PFB DBBCs, none =
                        never use dbbc=vsi_align=... (default) 0 = always use
                        dbbc=vsi_align=0 1 = always use dbbc=vsi_align=1 [env
                        var: FESH_GEO_VSI_ALIGN]
  --ContCalAction CONTCALACTION
                        Drudg config: Continuous cal option. Either 'on' or
                        'off'. Default is 'off' [env var: FESH_GEO_CONT_CAL]
  --ContCalPolarity CONTCALPOLARITY
                        Drudg config: If continuous cal is in use, what is the
                        polarity? Options are 0-3 or 'none'. [env var:
                        FESH_GEO_CONT_CAL_POLARITY]
  --SetupProc SETUPPROC
                        Drudg config: the answer for the drudg prompt for the
                        use setup_proc for geodesy schedules, an option to
                        write a `.snp` file that skips setup on scans when the
                        mode hasn’t changed. [env var:
                        FESH_GEO_USE_SETUP_PROC]
  --VdifSingleThreadPerFile VDIFSINGLETHREADPERFILE
                        VDIF single thread per file: only applies to Mark5C or
                        Flexbuff recorders. Can be 'yes' or 'no' [env var:
                        FESH_GEO_VDIF_SINGLE_THREAD_PER_FILE]
  --Servers [SERVERS [SERVERS ...]]
                        Schedule file server URLs. Each of these will be
                        checked for the most recent files. Use comma-separated
                        URLs and specify the top directory (i.e. the 'vlbi'
                        directory). Use protocols https (Curl), ftp (anonymous
                        FTP) or sftp (anonymous secure FTP)
  --NetrcFile NETRCFILE
                        The location of the .netrc file, needed by CURL for
                        the https protocol. (CURL puts this in ~/.netrc by
                        default) [env var: NETRC_FILE]
  --CookiesFile COOKIESFILE
                        The location of the .urs_cookies files used by CURL.
                        (CURL puts this in ~/.urs_cookies by default) [env
                        var: COOKIES_FILE]
  --CurlSecLevel1 [CURLSECLEVEL1]
                        Workaround for CDDIS https access in some Debian
                        distributions. See the documentation (default = False)
  -y YEAR, --year YEAR  The year of the Master Schedule (default is this year)
  -e, --check           Check the current fesh2 status. Shows the status of
                        schedule files and when schedule servers were last
                        queried.
  --monit               Similar to --check but text output format is intended
                        for a FS monit interface
  -q, --quiet           Runs fesh2 with all terminal output suppressed. Useful
                        when running fesh2 as a service.
```

## Logging

As well as writing information to the screen on activity, **fesh2** also keeps a
log of activity in the Field System log directory (by default) at
`/usr2/log/fesh2.log`. The log file location can be configured in `fesh2.config`

## Running fesh2 as a service

Fesh2 can be run in the background as a `systemd` service. All output is
suppressed and status is available by examining the log file or using the
`--check` or `-e` flag. Here's how to set it up from the superuser account for
Debian Jessie or later:

1. Type the following command to add a `systemd` service:
    ```
   systemctl edit --force --full fesh2.service
   ```
   This should open a text editor. Paste in the following:
    ```
   [Unit]
   Description=Fesh2 Service
   After=network-online.target
   Wants=network-online.target
   
   [Service]
   ExecStart=/usr/bin/sudo -H -u oper /usr/local/bin/fesh2 --quiet
   
   [Install]
   WantedBy=multi-user.target
   ```
   Save and exit. This will configure `systemd` to start fesh2, running as user
   oper and suppress all output.
2. Enable the service:
    ```
    sudo systemctl enable fesh2.service
    ```
3. Check the status of the service:
    ```
    sudo systemctl status fesh2.service
    ```
4. You can stop, start and query the service:
    ```
    sudo systemctl stop fesh2.service          # Stop running the service 
    sudo systemctl start fesh2.service         # Start running the service 
    sudo systemctl restart fesh2.service       # Restart the service 
    ```
5. To see the current schedule file status (as user oper):
    ```
   fesh2 --check
   ```

If you would prefer to set this up as a user service, some notes are here:
* https://www.unixsysadmin.com/systemd-user-services/

For versions of Debian older thean Jessie (e.g. Wheezy), systemd can be enabled
and some notes are here:
* https://scottlinux.com/2014/10/20/how-to-switch-to-systemd-on-debian-wheezy/

