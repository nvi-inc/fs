
# Tests

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


* 
* Flow of parameter setting. Command-line to Env to config
* make sure skedf.ctl parameters are dealt with correctly
* Try setting sched directory to '.'
* check config parameters are interpreted correctly when comma-separated
 (stations and schedtypes)
* does fesh2 handle non-defined parameters in fesh2.config correctly?
* new schedule scenario
* check scenario
* force update scenario
* log file content
* python v 2.7.16, 3.5.3, 3.7.3
* run for an extended period

Item | 2.7.16 | 3.5.3 | 3.7.3
---- | --- | --- | ---
skedf and fesh2 config files flow | | |
env variables trump config | Y | Y | Y
command-line trumps all | Y | Y | Y
-h, --help | Y | Y | Y
-c CONFIGFILE, --ConfigFile CONFIGFILE | Y | Y | Y
-g G  | Y | Y | Y
-m, --master-update | Y | Y | Y
-u, --sched-update | Y | Y | Y
-n, --current, --now | Y | Y | Y
-a, --all              | Y | Y | Y
-o, --once             | Y | Y | Y
--update               | Y | Y | Y
--SchedDir SCHEDDIR    | Y | Y | Y
--ProcDir PROCDIR      | Y | Y | Y
--SnapDir SNAPDIR      | Y | Y | Y
--LstDir LSTDIR        | Y | Y | Y
--LogDir LOGDIR        | Y | Y | Y
--Stations [STATIONS [STATIONS ...]]  | Y | Y | Y
--GetMaster            | Y | Y | Y
--GetMasterIntensive   | Y | Y | Y
--SchedTypes           | Y | Y | Y
-t MASTERCHECKTIME, --MasterCheckTime MASTERCHECKTIME  | Y | Y | Y
-s SCHEDULECHECKTIME, --ScheduleCheckTime SCHEDULECHECKTIME  | Y | Y | Y
-l LOOKAHEADTIMEDAYS, --LookAheadTimeDays LOOKAHEADTIMEDAYS  | Y | Y | Y
-d [DODRUDG], --DoDrudg [DODRUDG]  | Y | Y | Y
--DrudgBinary DRUDGBINARY  | Y | Y | Y
--TpiPeriod TPIPERIOD  |Y  | Y |  Y
--VsiAlign VSIALIGN    | | | Not tested
--ContCalAction CONTCALACTION  | Y | Y | Y
--ContCalPolarity CONTCALPOLARITY  | Y | Y | Y
--Servers [SERVERS [SERVERS ...]]  | Y | Y | Y
--NetrcFile NETRCFILE  | Y | Y | Y
--CookiesFile COOKIESFILE  | Y | Y | Y
--CurlSecLevel1        | Y | Y | Y
-y YEAR, --year YEAR   | Y | Y | Y
-e, --check            | Y | Y | Y
-q, --quiet            | Y | Y | Y
| | |
skedf '.' response | Y | | Y
skedf directories | Y | | Y
Ctrl-C | Y* | | Y
extended run | | Y |

    ssh -p 2223 jlovell@localhost
    cd Automation
    source env/bin/activate
    cd fesh2_test

environment variables trump config. Try setting LIST_DIR, NETRC_FILE
, COOKIES_FILE

    PYTHONUNBUFFERED=1;LIST_DIR=/tmp/;NETRC_FILE=/home/jlovell/.netrc
    ;COOKIES_FILE=/home/jlovell/.urs_cookies
    
Command line trumps all. 
* Keep above env vars and add

    --LstDir /usr2/proc --NetrcFile /home/jlovell/.notrc --CookiesFile /tmp
    check cnf

* Add:
            

skedf '.':
    
    cp ../test_files/skedf.ctl_dotsched /usr2/control/skedf.ctl
    run
    should raise and Exception and a message
    
skedf directories (set all to /tmp/):

    cp ../test_files/skedf.ctl_alltmp /usr2/control/skedf.ctl
    Set break point after config loaded
    run
    check contents of cnf
    cp ../test_files/skedf.ctl /usr2/control/skedf.ctl
    
command line parameters tests

    python3 -m fesh2 -h
    python3 -m fesh2 -c /home/jlovell/Automation/test_files/fesh2.config_-ctest
    python3 -m fesh2  -g r1974 
    python3 -m fesh2  -m, --master-update
    python3 -m fesh2  -u, --sched-update
    python3 -m fesh2  -n, --current, --now
    python3 -m fesh2  --Stations hb ke yg -a            
    python3 -m fesh2  -o, --once            
    python3 -m fesh2  --update  
        run to get a sched file, then change mod times. e.g.:
            python3 -m fesh2  -o   
            vi /usr2/sched/aov053.skd (change something)
            touch -m -t 202010101200 /usr2/*/aov053*
            python3 -m fesh2  -o
            (should see the warning)
            python3 -m fesh2 -o --update --DoDrudg -g aov053
                    
    mkdir /tmp/sched
    mkdir /tmp/proc                
    mkdir /tmp/snap                
    mkdir /tmp/lst                
    mkdir /tmp/log                
    python -m fesh2  -o --SchedDir /tmp/sched   
    python -m fesh2  -o --ProcDir /tmp/proc     
    python -m fesh2  -o --SnapDir /tmp/snap     
    python -m fesh2  -o --LstDir /tmp/lst       
    python -m fesh2  -o --LogDir /tmp/log  
        rm /tmp/*/aov*
        python -m fesh2  -o --LogDir /tmp/log --SchedDir /tmp/sched --ProcDir /tmp/proc --SnapDir /tmp/snap --LstDir /tmp/lst 
         
    python -m fesh2  --Stations hb ke yg
    python -m fesh2  -o --GetMaster False        
    python -m fesh2  -o --GetMasterIntensive False
    rm /usr2/*/aov*
    python -m fesh2  -o --SchedTypes vex
    python -m fesh2  -o --SchedTypes skd
    python -m fesh2  -o --SchedTypes vex skd
    
    python -m fesh2  -t 18
    python -m fesh2  --MasterCheckTime 18

    python -m fesh2  -s 14
    python -m fesh2  --ScheduleCheckTime 14
    
    python -m fesh2  -s 14 - t 18
    python -m fesh2  -s 18 - t 14

    python -m fesh2  -l 30
    python -m fesh2  --LookAheadTimeDays 12

    python -m fesh2  -d [DODRUDG], --DoDrudg [DODRUDG]
        rm /usr2/*/aov*
        python -m fesh2  -o -d False
        python -m fesh2  -o --DoDrudg False
        python -m fesh2  -o --DoDrudg

    python -m fesh2  --DrudgBinary DRUDGBINARY
        rm /usr2/*/aov*
        python -m fesh2  --DrudgBinary /usr2/fs/bin/drudg_same
        python -m fesh2  --DrudgBinary /usr2/fs/bin/drudg_same2
        
    python -m fesh2  --TpiPeriod TPIPERIOD
    python -m fesh2  --VsiAlign VSIALIGN   
    python -m fesh2  --ContCalAction CONTCALACTION
    python -m fesh2  --ContCalPolarity CONTCALPOLARITY
        rm /usr2/*/aov*
        python -m fesh2  --TpiPeriod 10 --VsiAlign 0 --ContCalAction on
         --ContCalPolarity 0
         
    python -m fesh2  --Servers https://cddis.nasa.gov/archive/vlbi
    python -m fesh2  --Servers ftp://ivs.bkg.bund.de/pub/vlbi https://cddis.nasa.gov/archive/vlbi
    
    python -m fesh2  --NetrcFile NETRCFILE  see above
    python -m fesh2  --CookiesFile COOKIESFILE see above

    python -m fesh2  --CurlSecLevel1 False      
    python -m fesh2  --CurlSecLevel1 True      

    python -m fesh2  -y 2019
     
    python -m fesh2  -e, --check           
    python -m fesh2  -q, --quiet           


## environment variable testing:
PYTHONUNBUFFERED=1;FESH_GEO_VSI_ALIGN=F;FESH_GEO_TPICD=A;FESH_GEO_CONT_CAL=B;FESH_GEO_CONT_CAL_POLARITY=C;FESH_GEO_USE_SETUP_PROC=D;FESH_GEO_VDIF_SINGLE_THREAD_PER_FILE=E;NETRC_FILE=/fred/netrc.txt;COOKIES_FILE=/fred/cookies.txt;LIST_DIR=/usr2/control

## Testing of email send from Python
Sent at 06:59 UT on Sep 22
First to @yahoo, then @gmail and then @utas

UTAS transcript:
jelovel1@gsvvmgo-fs-02:~$ python3 test05SMTP.py
send: 'ehlo [172.19.20.135]\r\n'
reply: b'250-ndjsvasmtp102.ndc.nasa.gov\r\n'
reply: b'250-PIPELINING\r\n'
reply: b'250-SIZE 20480000\r\n'
reply: b'250-ETRN\r\n'
reply: b'250-STARTTLS\r\n'
reply: b'250-ENHANCEDSTATUSCODES\r\n'
reply: b'250-8BITMIME\r\n'
reply: b'250 DSN\r\n'
reply: retcode (250); Msg: b'ndjsvasmtp102.ndc.nasa.gov\nPIPELINING\nSIZE 20480000\nETRN\nSTARTTLS\nENHANCEDSTATUSCODES\n8BITMIME\nDSN'
send: 'mail FROM:<jelovel1@fs2-mg.sgp.nasa.gov> size=292\r\n'
reply: b'250 2.1.0 Ok\r\n'
reply: retcode (250); Msg: b'2.1.0 Ok'
send: 'rcpt TO:<Jim.Lovell@utas.edu.au>\r\n'
reply: b'250 2.1.5 Ok\r\n'
reply: retcode (250); Msg: b'2.1.5 Ok'
send: 'data\r\n'
reply: b'354 End data with <CR><LF>.<CR><LF>\r\n'
reply: retcode (354); Msg: b'End data with <CR><LF>.<CR><LF>'
data: (354, b'End data with <CR><LF>.<CR><LF>')
send: b'Content-Type: text/plain; charset="utf-8"\r\nContent-Transfer-Encoding:
7bit\r\nMIME-Version: 1.0\r\nSubject: Python from fs2 exim4 server\r\nFrom: jelovel1@fs2-mg.sgp.nasa.gov\r\nTo: Jim.Lovell@utas.edu.au\r\n\r\nHello,\r\n\r\nThis is a test of sending email from fs2 using Python smtplib.\r\n\r\nJim Lovell\r\n\r\n\r\n.\r\n'
reply: b'250 2.0.0 Ok: queued as 40C204011465\r\n'
reply: retcode (250); Msg: b'2.0.0 Ok: queued as 40C204011465'
data: (250, b'2.0.0 Ok: queued as 40C204011465')
send: 'ehlo [172.19.20.135]\r\n'
reply: b'250-ndjsvasmtp102.ndc.nasa.gov\r\n'
reply: b'250-PIPELINING\r\n'
reply: b'250-SIZE 20480000\r\n'
reply: b'250-ETRN\r\n'
reply: b'250-STARTTLS\r\n'
reply: b'250-ENHANCEDSTATUSCODES\r\n'
reply: b'250-8BITMIME\r\n'
reply: b'250 DSN\r\n'
reply: retcode (250); Msg: b'ndjsvasmtp102.ndc.nasa.gov\nPIPELINING\nSIZE 20480000\nETRN\nSTARTTLS\nENHANCEDSTATUSCODES\n8BITMIME\nDSN'
send: 'quit\r\n'
reply: b'221 2.0.0 Bye\r\n'
reply: retcode (221); Msg: b'2.0.0 Bye'

# Version 2.2.3 testing

### Testing on pcfs-2ho (python 3.7.3):
    pcfs-2ho
    cd /usr2/oper/jlovell/fs_testing/fesh2
    python3 -m fesh2

### Testing on ubuntu virtual machine (pythton 3.5.3)
    ssh -p 2223 jlovell@localhost
    cd Automation
    source env/bin/activate
    cd fesh2_test


Item |  3.5.3 | 3.7.3
---- |  --- | ---
skedf and fesh2 config files flow | | Y
env variables trump config | |  Y
command-line trumps all | |  Y
-h, --help | |  Y
-c CONFIGFILE, --ConfigFile CONFIGFILE | |  Y
-k SKEDCONFIGFILE | | Y
-g GET  | |  Y
-m, --master-update | |  Y
-u, --sched-update | |  Y
-n, --current, --now | |  Y
-a, --all              | |  Y
-o, --once             | |  Y
--update               | |  Y
new sched warning      | | Y
--SchedDir SCHEDDIR    | | Y
--ProcDir PROCDIR      | |  Y
--SnapDir SNAPDIR      | |  Y
--LstDir LSTDIR        | |  Y
--LogDir LOGDIR        | |  Y
--Stations [STATIONS [STATIONS ...]]  | | Y  
--EmailNotifications [EMAILNOTIFICATIONS] | | Y
--GetMaster            | |  Y
--GetMasterIntensive   | |  Y
--SchedTypes           | |  Y
-t MASTERCHECKTIME, --MasterCheckTime MASTERCHECKTIME  | |  Y
-s SCHEDULECHECKTIME, --ScheduleCheckTime SCHEDULECHECKTIME  | | Y 
-l LOOKAHEADTIMEDAYS, --LookAheadTimeDays LOOKAHEADTIMEDAYS  | |  Y
-d [DODRUDG], --DoDrudg [DODRUDG]  | |  Y
--DrudgBinary DRUDGBINARY  | |  Y
--TpiPeriod TPIPERIOD  |  |  Y
--VsiAlign VSIALIGN    | | | Not tested
--ContCalAction CONTCALACTION  | | Y  
--ContCalPolarity CONTCALPOLARITY  | | Y 
--SetupProc SETUPPROX | | Not tested
--VdifSingleThreadPerFile VDIFSINGLETHREADPERFILE | | Not tested
--Servers [SERVERS [SERVERS ...]]  | |  Y
--NetrcFile NETRCFILE  | |  Y
--CookiesFile COOKIESFILE  | | Y  
--CurlSecLevel1        | |  Y
-y YEAR, --year YEAR   | |  Y
-e, --check            | |  Y
--monit | | Y
-q, --quiet            | | Y  
| | |
skedf '.' response |  | Y
Ctrl-C |  | Y
extended run | |  

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
    

### command line parameters tests
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

## environment variable testing:
PYTHONUNBUFFERED=1;FESH_GEO_VSI_ALIGN=F;FESH_GEO_TPICD=A;FESH_GEO_CONT_CAL=B;FESH_GEO_CONT_CAL_POLARITY=C;FESH_GEO_USE_SETUP_PROC=D;FESH_GEO_VDIF_SINGLE_THREAD_PER_FILE=E;NETRC_FILE=/fred/netrc.txt;COOKIES_FILE=/fred/cookies.txt;LIST_DIR=/usr2/control
