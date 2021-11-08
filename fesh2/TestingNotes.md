
# Fesh2 tests

## Prepare a distro
* edit setup.py and _version.py to set the version number

```
cd Dropbox/Projects/NASA/fs/fesh2
python3 setup.py sdist bdist_wheel
twine check dist/*
scp dist/fesh2-2.2.2.tar.gz oper@pcfs-2ho.phys.utas.edu.au:
```
Then on pcfs-2ho, login as root, then:

```pip3 install --upgrade ~oper/fesh2-2.2.2.tar.gz```

Alternatively:
```
twine upload --repository-url https://test.pypi.org/legacy/ dist/*
```
Then install on PC using pip3 install upgrade fesh2



## Testing of email send from Python
Works from UTAS but some config tweaking will be required for SGP sites. 
This needs to be tested e.g. at MGO

# Version 2.2.x testing

### Testing on pcfs-2ho (Python 3.7.3):
    pcfs-2ho
    cd /usr2/oper/jlovell/fs_testing/fesh2
    python3 -m fesh2



Item | Tested? (Python 3.7.3)
---- |   ---
skedf and fesh2 config files flow |  Y
env variables trump config |   Y
command-line trumps all |   Y
-h, --help |   Y
-c CONFIGFILE, --ConfigFile CONFIGFILE |   Y
-k SKEDCONFIGFILE |  Y
-g GET  |   Y
-m, --master-update |   Y
-u, --sched-update |   Y
-n, --current, --now |   Y
-a, --all              |   Y
-o, --once             |   Y
--update               |   Y
new sched warning      |  Y
--SchedDir SCHEDDIR    |  Y
--ProcDir PROCDIR      |   Y
--SnapDir SNAPDIR      |   Y
--LstDir LSTDIR        |   Y
--LogDir LOGDIR        |   Y
--Stations [STATIONS [STATIONS ...]]  |  Y  
--EmailNotifications [EMAILNOTIFICATIONS] |  Y
--GetMaster            |   Y
--GetMasterIntensive   |   Y
--SchedTypes           |   Y
-t MASTERCHECKTIME, --MasterCheckTime MASTERCHECKTIME  |   Y
-s SCHEDULECHECKTIME, --ScheduleCheckTime SCHEDULECHECKTIME  |  Y 
-l LOOKAHEADTIMEDAYS, --LookAheadTimeDays LOOKAHEADTIMEDAYS  |   Y
-d [DODRUDG], --DoDrudg [DODRUDG]  |   Y
--DrudgBinary DRUDGBINARY  |   Y
--TpiPeriod TPIPERIOD  |  |  Y
--VsiAlign VSIALIGN    |  | Not tested
--ContCalAction CONTCALACTION  |  Y  
--ContCalPolarity CONTCALPOLARITY  |  Y 
--SetupProc SETUPPROX |  Not tested
--VdifSingleThreadPerFile VDIFSINGLETHREADPERFILE |  Not tested
--Servers [SERVERS [SERVERS ...]]  |   Y
--NetrcFile NETRCFILE  |   Y
--CookiesFile COOKIESFILE  |  Y  
--CurlSecLevel1        |   Y
-y YEAR, --year YEAR   |   Y
-e, --check            |   Y
--monit |  Y
-q, --quiet            |  Y  
|  |
skedf '.' response |  Y
Ctrl-C |  Y
extended run |   Y

### try out a test installation:
```
cd /usr2/oper/jlovell/fs_testing/fesh2
pip3 install --upgrade .
```

### skedf and fesh2 config files flow
Look for a parameter in skedf, make the equivalent different in fesh2.config 
and see if it picks up the fesh2.config version

### Command line trumps all. 
* Keep above env vars and add

    --LstDir /usr2/proc --NetrcFile /home/jlovell/.notrc --CookiesFile /tmp
  * Note: If e.g. LstDir is set but you have a monit process running with no 
    options, sched will come back as unprepared, even though it is, because 
    monit is looking in the wrong directory!  

### bad skd dir config
* Edit /usr2/control/skedf.ctl and comment out sked dir. Running fesh2 
  should raise an exception and a message 
* Add skedf .
  
     ```cp ../test_files/skedf.ctl_dotsched /usr2/control/skedf.ctl```

    * run 
    * should raise and Exception and a message

### skedf directories (set all to `/tmp/`):

```cp ../test_files/skedf.ctl_alltmp /usr2/control/skedf.ctl```

Set break point after config loaded:
* run
* check contents of cnf
* `cp ../test_files/skedf.ctl /usr2/control/skedf.ctl`

## environment variable testing:
```
PYTHONUNBUFFERED=1;FESH_GEO_VSI_ALIGN=F;FESH_GEO_TPICD=A;FESH_GEO_CONT_CAL=B;FESH_GEO_CONT_CAL_POLARITY=C;FESH_GEO_USE_SETUP_PROC=D;FESH_GEO_VDIF_SINGLE_THREAD_PER_FILE=E;NETRC_FILE=/fred/netrc.txt;COOKIES_FILE=/fred/cookies.txt;LIST_DIR=/usr2/control
```



### command line parameters tests: commands
```
    fesh2 -h
    fesh2 -c /home/jlovell/Automation/test_files/fesh2.config_-ctest
    fesh2  -g r1974 
    fesh2  -m, --master-update
    fesh2  -u, --sched-update
    fesh2  -n, --current, --now
    fesh2  --Stations hb ke yg -a            
    fesh2  -o, --once            
    fesh2  --update
    new sched warning:
        run to get a sched file, then change mod times. e.g.:
            rm /usr2/*/aum041*
            fesh2  -o   
            vi /usr2/sched/aum041.skd (change something)
            touch -m -t 202010101200 /usr2/*/aum041*
            fesh2  -o -s 0.001
            (should see the warning and get an email)
            fesh2 -o --update --DoDrudg -g aum041
                    
    mkdir /tmp/sched
    mkdir /tmp/proc                
    mkdir /tmp/snap                
    mkdir /tmp/lst                
    mkdir /tmp/log                
    fesh2  -o --SchedDir /tmp/sched   
    fesh2  -o --ProcDir /tmp/proc     
    fesh2  -o --SnapDir /tmp/snap     
    fesh2  -o --LstDir /tmp/lst       
    fesh2  -o --LogDir /tmp/log  
        rm /tmp/*/aum*
        fesh2  -o --LogDir /tmp/log --SchedDir /tmp/sched --ProcDir /tmp/proc --SnapDir /tmp/snap --LstDir /tmp/lst 
         
    fesh2  --Stations hb ke yg
    fesh2 --EmailNotifications False -o
    fesh2  -o --GetMaster False        
    fesh2  -o --GetMasterIntensive False
    rm /usr2/*/aov*
    fesh2  -o --SchedTypes vex
    fesh2  -o --SchedTypes skd
    fesh2  -o --SchedTypes vex skd
    
    fesh2  -o -t 18
    fesh2  -o --MasterCheckTime 18

    fesh2  -o -s 14
    fesh2  -o --ScheduleCheckTime 14
    
    fesh2 -o  -s 14 -t 18
    fesh2  -o -s 18 -t 14

    fesh2  -o -l 30
    fesh2  -o --LookAheadTimeDays 12

    fesh2  -d [DODRUDG], --DoDrudg [DODRUDG]
        rm /usr2/*/aov*
        fesh2  -o -d False
        fesh2  -o --DoDrudg False
        fesh2  -o --DoDrudg

    fesh2  --DrudgBinary DRUDGBINARY
        rm /usr2/*/aov*
        cp /usr2/fs/bin/drudg /usr2/oper/jlovell/fs_testing/mydrudg
        fesh2 -o --DrudgBinary /usr2/oper/jlovell/fs_testing/mydrudg
        
    CONT_CAL etc:
        rm /usr2/*/aum041*
        cp /usr2/control/skedf_test.ctl /usr2/control/skedf.ctl
        fesh2  --TpiPeriod 10 --VsiAlign 0 --ContCalAction on --ContCalPolarity 0
        cp /usr2/control/skedf_safe.ctl /usr2/control/skedf.ctl
         
    fesh2 -o --Servers https://cddis.nasa.gov/archive/vlbi
    fesh2 -o --Servers ftp://ivs.bkg.bund.de/pub/vlbi https://cddis.nasa.gov/archive/vlbi
    
    python -m fesh2  --NetrcFile NETRCFILE  see above
    python -m fesh2  --CookiesFile COOKIESFILE see above

    Set DEBUG=True in  /usr2/oper/jlovell/venvs/py3env/lib/python3.7/site-packages/fesh2/__main__.py
    fesh2 -o --CurlSecLevel1 False      
    fesh2 -o  --CurlSecLevel1 True      

    fesh2 -o -y 2020
     
    fesh2  -e, --check           
    fesh2  -q, --quiet           
```
