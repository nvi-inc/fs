#!/usr/bin/env python3

import sys
import configparser
from configparser import ExtendedInterpolation
from os import path
import string

class Config:

    def __init__(self):
        # recognised schedule file types
        self.allowed_sched_types = ['vex', 'skd']

        def parse_onoff(val):
            val = val.lower()
            if val in ['on', 'off']:
                return val
            else:
                return 'off'

        def parse_ccal_pol(val):
            val = val.lower()
            if val in ['none', '0', '1', '2', '3']:
                return val
            else:
                return 'none'

        def parse_vsi_align(val):
            val = val.lower()
            if val in ['none', '0', '1']:
                return val
            else:
                return 'none'

        #        self.config = configparser.ConfigParser(interpolation=ExtendedInterpolation())
        self.config = configparser.ConfigParser(
            converters = {'onoff': parse_onoff,
                          'contcalpol': parse_ccal_pol,
                          'vsialign': parse_vsi_align}
        )
        self.config._interpolation = ExtendedInterpolation()
        self.logger = None
        self.stations = []
        self.servers = []
        self.sched_types = []
        self.master_check_interval = 24
        self.sched_check_interval = 1
        self.sched_look_ahead_time_d = 7
        self.tpi_period = 0
        self.cont_cal_action = "off"
        self.cont_cal_polarity = "none"
        self.vsi_align = "none"
        self.do_drudg = True
        # These default parameters are command-line options only. We transfer them to this structure in the "load" routine
        self.get_session = None # Just look for schedules from this session
        self.force_master_update = False # Force a download of the master file(s)
        self.force_sched_update = False # Force a download of the schedule file(s)
        self.current = False # Only process the current or next experiment
        self.run_once = False # Only check schedules once, then exit. No wait loop
        self.all_stations = False # get the first session with all the names stations
        self.year = None # Which year to check.


    def load(self, arg):
        # arg is an Args instance

        # Check that the config file exists (the default is set in Args.)
        if not path.exists(arg.args.config):
            raise OSError(2, "Can't find the config file: ", arg.args.config)
        print("Config file found: {}".format(arg.args.config))
        # Read the config file
        self.config.read(arg.args.config)

        # If snts=[] then nothing set on the command line, so use the config file
        if len(arg.args.stns) > 0:
            # station names given on the command line
            self.stations = arg.args.stns
        else:
            stns = self.config['Station']['stations']
            self.stations = [word.strip(string.punctuation) for word in stns.split()]
        # convert station names to lower case`
        self.stations = list(map(lambda x: x.lower(), self.stations))

        # get list of file servers
        servs = self.config['Servers']['url']
        self.servers = [word.strip(string.punctuation) for word in servs.split()]

        # get prioritised list of schedule file formats
        types = self.config['Station']['schedtypes']
        self.sched_types = [word.strip(string.punctuation) for word in types.split()]

        try:
            if arg.args.tmaster is not None:
                self.master_check_interval = float(arg.args.tmaster)
            else:
                self.master_check_interval = self.config.getfloat('Station', 'masterchecktime')
        except ValueError as err:
            print("ERROR: Can't interpret MasterCheckTime in config file. Not a number?: {}".format(err))
            print("Setting the Master File check interval to 24 hours.")
            self.master_check_interval = 24
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise

        try:
            if arg.args.tsched is not None:
                self.sched_check_interval = float(arg.args.tsched)
            else:
                self.sched_check_interval = self.config.getfloat('Station', 'schedulechecktime')
        except ValueError as err:
            print("ERROR: Can't interpret ScheduleCheckTime in config file. Not a number?: {}".format(err))
            print("Setting the Schedule File check interval to 1 hour.")
            self.sched_check_interval = 1
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise

        try:
            if arg.args.lookahead is not None:
                self.sched_look_ahead_time_d = int(arg.args.lookahead)
            else:
                self.sched_look_ahead_time_d = self.config.getint('Station', 'lookaheadtimedays')
        except ValueError as err:
            print("ERROR: Can't interpret LookAheadTimeDays in config file. Not an integer?: {}".format(err))
            print("Setting the Schedule File look-ahead time to 7 days.")
            self.sched_look_ahead_time_d = 7
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise

        if arg.args.no_drudg:
            self.do_drudg = False
        if arg.args.get:
            self.get_session = arg.args.get
        if arg.args.master_update:
            self.force_master_update = True
        if arg.args.sched_update:
            self.force_sched_update = True
        if arg.args.current:
            self.current = True
        if arg.args.once:
            self.run_once = True
        if arg.args.all:
            self.all_stations = True
        self.year = arg.args.year

        self.tpi_period = self.config.getint('Drudg', 'tpi_period')
        self.cont_cal_action = self.config.getonoff('Drudg', 'cont_cal_action')
        self.cont_cal_polarity = self.config.getcontcalpol('Drudg', 'cont_cal_polarity')
        self.vsi_align = self.config.getvsialign('Drudg', 'vsi_align')

    def check(self):
        # Check the configuration
        print("Configuration check")

        # Servers
        if not self.servers:
            raise Exception("Config file must specify at least one schedule server in [Servers] section")

        if not self.sched_types:
            raise Exception("Config file must specify at least one schedule file type in [Station] section")
        for s in self.sched_types:
            if s not in self.allowed_sched_types:
                raise Exception("Config file has unrecognised schedule file format '{}' ([Station] section)".format(s))

        # Stations text format
        if not self.stations:
            raise Exception("Config file must specify at least one station in [Station] section")

        for s in self.stations:
            if len(s) != 2:
                msg = 'Station name length wrong: "{}". Should be two characters.'.format(s)
                raise Exception(msg)

        # FS directories exist?
        if not path.exists(self.config['FS']['fs_dir']):
            raise OSError(2, "Can't find the Field System directory specified in the config file: ",
                          self.config['FS']['fs_dir'])

        if not path.exists(self.config['FS']['st_dir']):
            raise OSError(2, "Can't find the Field System directory specified in the config file: ",
                          self.config['FS']['st_dir'])

        # curl files
        if not path.exists(self.config['Curl']['netrc_file']):
            raise OSError(2, "Can't find the netrc file (needed for curl) specified in the config file: ",
                          self.config['Curl']['netrc_file'])

        if not path.exists(self.config['Curl']['cookie_file']):
            raise OSError(2, "Can't find the netrc file (needed for curl) specified in the config file: ",
                          self.config['Curl']['cookie_file'])

        # Drudg paths exist?
        if not path.exists(self.config['Drudg']['binary']):
            raise OSError(2, "Can't find the drudg executable. Check the config file is correct: ",
                          self.config['Drudg']['binary'])
        if not path.exists(self.config['Drudg']['lst_dir']):
            raise OSError(2, "Can't find the directory for the Drudg LST file. Check the config file is correct: ",
                          self.config['Drudg']['lst_dir'])
