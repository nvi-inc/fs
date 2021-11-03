#!/usr/bin/env python3
import datetime
import logging
import re
import string
import sys
from collections import OrderedDict
from configparser import ConfigParser, ExtendedInterpolation
from datetime import datetime
from os import path

import configargparse

logger = logging.getLogger(__name__)


class Config:
    def __init__(self):
        # recognised schedule file types
        self.allowed_sched_types = ["vex", "skd"]

        def _parse_onoff(val):
            val = val.lower()
            if val in ["on", "off"]:
                return val
            else:
                return "off"

        def _parse_ccal_pol(val):
            val = val.lower()
            if val in ["none", "0", "1", "2", "3"]:
                return val
            else:
                return "none"

        def _parse_vsi_align(val):
            val = val.lower()
            if val in ["none", "0", "1"]:
                return val
            else:
                return "none"

        self.config = ConfigParser(
            converters={
                "onoff": _parse_onoff,
                "contcalpol": _parse_ccal_pol,
                "vsialign": _parse_vsi_align,
            }
        )
        self.config._interpolation = ExtendedInterpolation()

        self.ProcDir = "/usr2/proc"
        self.SchedDir = "/usr2/sched"
        # ------------------------------------------------------------------------------------------
        # parameters found in fesh2.config:
        # FS --------------------------------------
        self.LogDir = "/usr2/log"
        # Station ---------------------------------
        self.Stations = ["Hb", "Ho", "Ke", "Yg"]
        self.GetMaster = True
        self.GetMasterIntensive = True
        self.SchedTypes = ["vex", "skd"]
        self.MasterCheckTime = 12.0
        self.ScheduleCheckTime = 1.0
        self.LookAheadTimeDays = 14.0
        # Email -----------------------------------
        self.EmailNotifications = False
        self.EmailRecipients = []
        self.EmailServer = ""
        self.SMTPPort = 0
        self.EmailSender = ""
        self.EmailPassword = ""
        # Drudg -----------------------------------
        self.DoDrudg = True
        self.DrudgBinary = "/usr2/fs/bin/drudg"
        self.SnapDir = "/usr2/sched"
        self.LstDir = "/usr2/sched"
        self.TpiPeriod = 0
        self.ContCalAction = "off"
        self.ContCalPolarity = "none"
        self.VsiAlign = "none"
        self.SetupProc = None
        self.VdifSingleThreadPerFile = None
        # Servers ---------------------------------
        self.Servers = [
            "https://cddis.nasa.gov/archive/vlbi",
            "ftp://ivs.bkg.bund.de/pub/vlbi",
            "ftp://ivsopar.obspm.fr/pub/vlbi",
        ]
        # Curl ------------------------------------
        self.NetrcFile = ""
        self.CookiesFile = ""
        self.CurlSecLevel1 = False
        # ------------------------------------------------------------------------------------------
        # Things not in the config file:
        self.force_master_update = False
        self.force_sched_update = False
        self.run_once = False
        self.update = False
        self.all_stations = False
        self.check = False
        self.monit = False
        self.ConfigFile = None
        self.current = False
        self.get = None  # Just look for schedules from this session
        self.master_update = False  # Force a download of the master file(s)
        self.once = False
        self.quiet = True
        self.sched_update = False  # Force a download of the schedule file(s)
        self.year = 2020
        self.logger = None

        # Set up a dictionary for the Text Interface
        self.tui_data = self._setup_tui_info()

    def _setup_tui_info(self):
        tui_dict = {
            "title": "",
            "station_caption": "",
            "processes": "",  # info on number of fesh processes running
            "status_station_header": "",
            "master_header": "",
            "vartxt_24h": "",
            "vartxt_int": "",
            "reprocess_note": False,
            "sessions": None,
        }

        return tui_dict

    def load(self, arg):
        # arg is an Args instance
        # if arg is a tuple of length 2 then configargparse:parse_known_args()
        # has been called and returned a there may be unprocessed arguments in arg[1].
        # arg[0] is a Namespace with all processed arguments while arg[1] contains unprocessed
        # parameters that are in the config files but not
        # command-line options

        extra_args = []
        if isinstance(arg.args, tuple):
            args = arg.args[0]
            extra_args = arg.args[1]
        elif isinstance(arg.args, configargparse.Namespace):
            args = arg.args
        else:
            raise RuntimeError(
                "Unknown data type from configargparse (which "
                "interprets command-line, config files and env vars)."
            )

        if args.ProcDir:
            self.ProcDir = args.ProcDir.rstrip("/")
        if args.SchedDir:
            self.SchedDir = args.SchedDir.rstrip("/")
        # ------------------------------------------------------------------------------------------
        # parameters found in fesh2.config:
        # FS --------------------------------------
        if args.LogDir:
            self.LogDir = args.LogDir.rstrip("/")
        # Station ---------------------------------
        self.Stations = [word.strip(string.punctuation) for word in args.Stations]
        # convert station names to lower case`
        self.Stations = list(map(lambda x: x.lower(), self.Stations))
        self.GetMaster = args.GetMaster
        self.GetMasterIntensive = args.GetMasterIntensive
        # get prioritised list of schedule file formats
        self.SchedTypes = [word.strip(string.punctuation) for word in args.SchedTypes]
        self.MasterCheckTime = args.MasterCheckTime
        self.ScheduleCheckTime = args.ScheduleCheckTime
        self.LookAheadTimeDays = args.LookAheadTimeDays
        # Email -----------------------------------
        if args.EmailNotifications:
            self.EmailNotifications = args.EmailNotifications
        # These Email options are config-file only
        self.EmailRecipients = self._get_arg_from_extra_args(
            extra_args, "EmailRecipients"
        )
        self.EmailSender = self._get_arg_from_extra_args(extra_args, "EmailSender")
        self.EmailServer = self._get_arg_from_extra_args(extra_args, "EmailServer")
        self.EmailPassword = self._get_arg_from_extra_args(extra_args, "EmailPassword")
        self.SMTPPort = self._get_arg_from_extra_args(extra_args, "EmailPort")
        # Drudg -----------------------------------
        self.DoDrudg = args.DoDrudg
        self.DrudgBinary = args.DrudgBinary
        if args.SnapDir:
            self.SnapDir = args.SnapDir.rstrip("/")
        if args.LstDir:
            self.LstDir = args.LstDir.strip("'\\\"").rstrip("/")
        self.TpiPeriod = args.TpiPeriod
        self.ContCalAction = args.ContCalAction
        self.ContCalPolarity = args.ContCalPolarity
        self.VsiAlign = args.VsiAlign
        self.SetupProc = args.SetupProc
        self.VdifSingleThreadPerFile = args.VdifSingleThreadPerFile
        # Servers ---------------------------------
        # get list of file servers
        self.Servers = [word.strip(string.punctuation) for word in args.Servers]
        # Curl ------------------------------------
        self.NetrcFile = args.NetrcFile.strip("'\\\"")
        self.CookiesFile = args.CookiesFile.strip("'\\\"")
        self.CurlSecLevel1 = args.CurlSecLevel1
        # ------------------------------------------------------------------------------------------
        # Things not in the config file:
        if args.get:
            self.get = args.get
        self.force_master_update = args.master_update
        self.force_sched_update = args.sched_update
        self.current = args.current
        self.run_once = args.once
        self.all_stations = args.all
        self.check = args.check
        self.monit = args.monit
        self.quiet = args.quiet
        self.year = args.year
        self.update = args.update

    def check_config(self):
        # Check the configuration

        # Servers
        if not self.Servers:
            raise Exception(
                "Config file must specify at least one schedule server in [Servers] section"
            )

        if not self.SchedTypes:
            raise Exception(
                "Config file must specify at least one schedule file type in [Station] section"
            )
        for s in self.SchedTypes:
            if s not in self.allowed_sched_types:
                raise Exception(
                    "Config file has unrecognised schedule file format '{}' ([Station] section)".format(
                        s
                    )
                )

        # Stations text format
        if not self.Stations:
            raise Exception(
                "Config file must specify at least one station in [Station] section"
            )

        for s in self.Stations:
            if len(s) != 2:
                msg = (
                    'Station name length wrong: "{}". Should be two characters.'.format(
                        s
                    )
                )
                raise Exception(msg)

        # curl files
        if not path.exists(self.NetrcFile):
            raise OSError(
                2,
                "Can't find the specified netrc file (needed for curl): ",
                self.NetrcFile,
            )
        if not path.exists(self.CookiesFile):
            raise OSError(
                2,
                "Can't find the specified cookies file (needed for curl): ",
                self.CookiesFile,
            )

        # Drudg paths exist?
        if not path.exists(self.DrudgBinary):
            raise OSError(
                2,
                "Can't find the drudg executable. Check the config file is correct: ",
                self.DrudgBinary,
            )
        if not path.exists(self.SnapDir):
            raise OSError(
                2,
                "Can't find the directory for the SNAP file. Check the config file is correct: ",
                self.SnapDir,
            )
        if not path.exists(self.LogDir):
            raise OSError(
                2,
                "Can't find the directory for the Log file. Check the config file is correct: ",
                self.LogDir,
            )
        if not path.exists(self.LstDir):
            raise OSError(
                2,
                "Can't find the directory for the Drudg LST file. Check the config file is correct: ",
                self.LstDir,
            )

        if self.EmailNotifications:
            # check email addresses and server names make sense
            # from https://www.geeksforgeeks.org/check-if-email-address-valid-or-not-in-python/
            def email_syntax_ok(email):
                regex = r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"
                if re.fullmatch(regex, email):
                    return True  # Valid Email
                else:
                    return False  # invalid Email

            def server_syntax_ok(server):
                regex = r"^[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"
                if re.fullmatch(regex, server):
                    return True  # Valid server address
                else:
                    return False  # Inalid server address

            if not server_syntax_ok(self.EmailServer):
                raise RuntimeError(
                    "Invalid email server address: {}".format(self.EmailServer)
                )
            if not email_syntax_ok(self.EmailSender):
                raise RuntimeError(
                    "Invalid email sender address: {}".format(self.EmailSender)
                )
            for email in self.EmailRecipients:
                if not email_syntax_ok(email):
                    raise RuntimeError(
                        "Invalid email recipient address: {}".format(email)
                    )

    def _get_arg_from_extra_args(self, extra_args: list, parameter_name: str):
        """Given args and a parameter to search for, return the value as station_name_2ch or list of strs

        This is used for filtering results from configargparse, particularly when there are
        parameters not included on the command line

        Parameters
        ----------
        extra_args
            a list of arguments from configargparse. format is e.g. ['--parameter1=value',
            '--parameter2=value2', '--parameter2=value3']. is a parameter name is repeated,
            its values are returned as a list
        parameter_name
            the parameter name to search for
        Returns
        -------
        arg
            a string or list of strings containing the parameter values
            None = none found
        """

        arg = None  # default argument value to return
        if any(
            parameter_name in s for s in extra_args
        ):  # parameter_name is in extra_args
            search_string_indices = [s for s in extra_args if parameter_name in s]
            # value(s) of the parameter
            param_values = [
                word.split("=")[-1:][0].strip(string.whitespace)
                for word in search_string_indices
            ]
            len_indices = len(search_string_indices)
            # returnf a single value if there's only one, otherwise a list of them
            if len_indices == 1:
                arg = param_values[0]
            else:
                arg = param_values
        return arg


class Args:
    """This class uses the Argparse library to process config files and command-line arguments"""

    def __init__(
        self,
        default_config_file_skedf="/usr2/control/skedf.ctl",
        default_config_file_fesh="/usr2/control/fesh2.config",
    ):
        """Set up command-line parameters"""

        # Process the arguments once just so that the --help option produces a sensible output.
        # TODO: There must be a better way.
        help_parser = configargparse.ArgParser()
        help_parser = self.add_skedf_args(help_parser, "", "")
        help_parser = self.add_remaining_args(help_parser, {}, True)
        args_tmp = help_parser.parse_known_args()

        # Now process the arguments for real.

        # first we want to check the command-line params to see if the locations of the skedf and
        # fesh2 config files are correct
        parser_cfg_file_check = configargparse.ArgParser()
        self.add_skedf_args(
            parser_cfg_file_check, default_config_file_skedf, default_config_file_fesh
        )
        (config_file_args, remaining_args) = parser_cfg_file_check.parse_known_args()

        default_config_file_fesh = config_file_args.ConfigFile
        default_config_file_skedf = config_file_args.SkedConfigFile
        # Define a parser for skedf.ctl
        parser_skedf = configargparse.ArgParser(
            default_config_files=[default_config_file_skedf],
            config_file_parser_class=CustomConfigParser,
        )
        # Not setting up any arguments here. Getting args back as a list in args_skedf[1]. Use
        # these as default
        # values below, to be overriden by the fesh config file the command line, env_variables when
        # we run ArgParser
        args_skedf = parser_skedf.parse_known_args()

        items = OrderedDict()
        for keyval in args_skedf[1]:
            if "=" in keyval:
                (k, v) = keyval.split("=", 1)
                # print(k, v)
                items[k[2:]] = v
        # The schedules directory must be defined. Stop here if it's not
        if not "schedules" in items or not items["schedules"]:
            msg = (
                "\nFesh2 requires that $schedules is defined in skedf.ctl.\n"
                "The default of '.' (i.e. the directory the software is\n"
                "started in) is too arbitrary and could cause fesh2 to\n"
                "lose track of files. Fesh2 will not execute unless $schedules\n"
                "is defined. Exiting.\n"
            )
            raise Exception(msg)
        # Also check on other parameters that are used. Set defaults if they weren't set in
        # skedf.ctl. NOTE: These are the defaults that are set in the FS if not defined in skedf.ctl
        # We're just making sure they are preserved here.
        # TODO: This is a bit messy because if
        #  the FS default ever changes its defaults, we have to remember to duplicate the change
        #  here
        if not "misc.tpicd" in items:
            items["misc.tpicd"] = "NO 0"
        if not "misc.vsi_align" in items:
            items["misc.vsi_align"] = "NONE"
        if not "misc.cont_cal" in items:
            items["misc.cont_cal"] = "OFF"
        if not "misc.cont_cal_polarity" in items:
            items["misc.cont_cal_polarity"] = "NONE"
        if not "misc.use_setup_proc" in items:
            items["misc.use_setup_proc"] = "NO"
        if not "misc.vdif_single_thread_per_file" in items:
            items["misc.vdif_single_thread_per_file"] = "IGNORE"

        self.parser = configargparse.ArgParser(
            remaining_args,
            default_config_files=[default_config_file_fesh],
            description=(
                "Automated schedule file preparation for the current, next or specified session.\n\n"
                "A check for the latest version of the Master File(s) is done first, but skipped if the\n"
                "time since the last check is less than a specified amount (configureable on the command\n"
                "line or in the config file). Similarly, checks on schedule files are only done if the\n"
                "time since the last check exceeds a specified time.\nChecks can be forced on the command\n"
                "line."
            ),
        )

        self.add_remaining_args(self.parser, items)

        self.args = self.parser.parse_known_args()

    def add_skedf_args(
        self,
        parser_cfg_file_check: configargparse.ArgParser,
        default_config_file_skedf: str,
        default_config_file_fesh: str,
    ):
        parser_cfg_file_check.add_argument(
            "-c",
            "--ConfigFile",
            is_config_file=True,
            default=default_config_file_fesh,
            help="The fesh2 configuration file to use. e.g. /usr2/control/fesh2.config",
        )
        parser_cfg_file_check.add_argument(
            "-k",
            "--SkedConfigFile",
            is_config_file=True,
            default=default_config_file_skedf,
            help="The location of the skedf.cfg configuration file",
        )
        # parser_cfg_file_check.add_argument("rest", nargs=configargparse.REMAINDER)
        return parser_cfg_file_check

    def add_remaining_args(
        self, psr: configargparse.ArgParser, items: dict, no_defaults: bool = False
    ):
        now = datetime.utcnow()

        if no_defaults:
            items["schedules"] = None
            items["proc"] = None
            items["snap"] = None
            items["schedules"] = None
            items["misc.tpicd"] = None
            items["misc.vsi_align"] = None
            items["misc.cont_cal"] = None
            items["misc.cont_cal_polarity"] = None
            items["misc.use_setup_proc"] = None
            items["misc.vdif_single_thread_per_file"] = None

        psr.add_argument(
            "-g",
            "--get",
            default=None,
            help="Just get a schedule for this specified session. Give the name of the session (e.g. r4951).",
        )
        psr.add_argument(
            "-m",
            "--master-update",
            action="store_true",
            default=False,
            help="Force a download of the Master Schedule (default = False), but just on the first check cycle.",
        )

        psr.add_argument(
            "-u",
            "--sched-update",
            action="store_true",
            default=False,
            help="Force a download of the Schedules (default = False), but just on the first check cycle.",
        )

        psr.add_argument(
            "-n",
            "--current",
            "--now",
            action="store_true",
            default=False,
            help="Only process the current or next experiment",
        )
        psr.add_argument(
            "-a",
            "--all",
            action="store_true",
            help='Find the experiments with all "Stations" in it',
        )

        psr.add_argument(
            "-o",
            "--once",
            action="store_true",
            default=False,
            help="Just run once then exit, don't go into a wait loop (default = False)",
        )

        psr.add_argument(
            "--update",
            action="store_true",
            default=False,
            help="Force an update to the schedule file when there's a new one available to replace the old one. The "
            "default behaviour is to give the new file the name <code>.skd.new and prompt the user to take "
            "action. The file will also be drudged if the DoDrudg option is True",
        )

        psr.add_argument(
            "--SchedDir",
            default=items["schedules"],
            help="Schedule file directory",
        )

        psr.add_argument(
            "--ProcDir",
            default=items["proc"],
            help="Procedure (PRC) file directory",
        )

        psr.add_argument(
            "--SnapDir",
            default=items["snap"],
            help="SNAP file directory",
        )

        psr.add_argument(
            "--LstDir",
            default=items["schedules"],
            help="LST file directory",
            env_var="LIST_DIR",
        )

        psr.add_argument(
            "--LogDir",
            default="/usr2/log",
            help="Log file directory",
        )
        psr.add_argument(
            "--Stations",
            nargs="*",
            required=False,
            # default=['hb', 'ke', 'yg', 'ho'],
            type=self.station_label,
            help='Stations to consider (e.g. "hb ke yg ho", "mg")',
        )

        psr.add_argument(
            "--EmailNotifications",
            type=self._str2bool,
            const=True,
            default=False,
            nargs="?",
            help="Send notifications by email. The fesh2 config file will be read for details on "
            "mail server, recipients etc",
        )

        psr.add_argument(
            "--GetMaster",
            type=self._str2bool,
            const=True,
            default=True,
            nargs="?",
            help="Maintain a local copy of the main Multi-Agency schedule, i.e. mostly 24h sessions (default = True)",
        )

        psr.add_argument(
            "--GetMasterIntensive",
            type=self._str2bool,
            const=True,
            default=True,
            nargs="?",
            help="Maintain a local copy of the main Multi-Agency Intensive schedule (default = "
            "True)",
        )

        psr.add_argument(
            "--SchedTypes",
            nargs="*",
            default=["skd"],
            help="Schedule file formats to be obtained? This is a prioritised list with the "
            'highest priority first. Use the file name suffix ("vex" and/or "skd") and '
            "comma-separated.",
        )

        psr.add_argument(
            "-t",
            "--MasterCheckTime",
            type=float,
            help="Only check for a new master file if the last check "
            "was more than this number of hours ago. The default "
            "is set in the configuration file.",
        )

        psr.add_argument(
            "-s",
            "--ScheduleCheckTime",
            type=float,
            help="Only check for a new schedule file (SKD or VEX) if the last check "
            "was more than this number of hours ago. The default "
            "is set in the configuration file.",
        )

        psr.add_argument(
            "-l",
            "--LookAheadTimeDays",
            default=None,
            type=float,
            help="Only look for schedules less than this number of days away (default is 7)",
        )

        psr.add_argument(
            "-d",
            "--DoDrudg",
            type=self._str2bool,
            const=True,
            default=True,
            nargs="?",
            help="Run Drudg on the downloaded/updated schedules (default = True)",
        )

        psr.add_argument(
            "--DrudgBinary",
            default="/usr2/fs/bin/drudg",
            help="Location of Drudg executable (default = /usr2/fs/bin/drudg)",
            required=False,
        )

        psr.add_argument(
            "--TpiPeriod",
            default=items["misc.tpicd"],
            env_var="FESH_GEO_TPICD",
            help="Drudg config: TPI period in centiseconds. 0 = don't use the TPI daemon (default)",
        )

        psr.add_argument(
            "--VsiAlign",
            default=items["misc.vsi_align"],
            env_var="FESH_GEO_VSI_ALIGN",
            help="Drudg config: Applicable only for PFB DBBCs,\nnone = never use dbbc=vsi_align=... (default)\n0 = "
            "always use dbbc=vsi_align=0\n1 = always use dbbc=vsi_align=1",
        )

        psr.add_argument(
            "--ContCalAction",
            default=items["misc.cont_cal"],
            env_var="FESH_GEO_CONT_CAL",
            help="Drudg config: Continuous cal option. Either 'on' or 'off'. Default is 'off'",
        )
        #  3. If continuous cal is in use, what is the polarity? Options are 0-3 or "none". Default is none
        # ContCalPolarity = none
        psr.add_argument(
            "--ContCalPolarity",
            default=items["misc.cont_cal_polarity"],
            env_var="FESH_GEO_CONT_CAL_POLARITY",
            help="Drudg config: If continuous cal is in use, what is the polarity? Options are "
                 "0-3 or 'none'.",
        )

        psr.add_argument(
            "--SetupProc",
            default=items["misc.use_setup_proc"],
            env_var="FESH_GEO_USE_SETUP_PROC",
            help="Drudg config: the answer for the drudg prompt for the use setup_proc for "
                 "geodesy schedules, an option to write a `.snp` file that skips setup on scans "
                 "when the mode hasn’t changed.",
        )

        psr.add_argument(
            "--VdifSingleThreadPerFile",
            default=items["misc.vdif_single_thread_per_file"],
            env_var="FESH_GEO_VDIF_SINGLE_THREAD_PER_FILE",
            help="VDIF single thread per file: only applies to Mark5C or Flexbuff recorders. Can "
            "be 'yes' or 'no'",
        )

        psr.add_argument(
            "--Servers",
            nargs="*",
            default=[
                "https://cddis.nasa.gov/archive/vlbi",
                "ftp://ivs.bkg.bund.de/pub/vlbi",
                "ftp://ivsopar.obspm.fr/pub/vlbi",
            ],
            help="Schedule file server URLs. Each of these will be checked for the most recent files. Use "
            "comma-separated URLs and specify the top directory (i.e. the 'vlbi' directory). Use protocols https "
            "(Curl), ftp (anonymous FTP) or sftp (anonymous secure FTP)",
        )

        psr.add_argument(
            "--NetrcFile",
            default="/usr2/control/netrc_fesh2",
            env_var="NETRC_FILE",
            help="The location of the .netrc file, needed by CURL for the https protocol. (CURL puts "
            "this in ~/.netrc by default)",
        )

        psr.add_argument(
            "--CookiesFile",
            default="/dev/null/",
            env_var="COOKIES_FILE",
            help="The location of the .urs_cookies files used by CURL. (CURL puts this in "
            "~/.urs_cookies by default)",
        )

        psr.add_argument(
            "--CurlSecLevel1",
            type=self._str2bool,
            const=True,
            default=False,
            nargs="?",
            help="Workaround for CDDIS https access in some Debian distributions. See the documentation (default = "
            "False)",
        )

        # psr.add_argument('-p', '--tpi-period', default=None, type=int, help="TPI period in centiseconds (0
        # = don't use the TPI Daemon, default). This can be set in the config file.")

        psr.add_argument(
            "-y",
            "--year",
            default=now.year,
            type=int,
            help="The year of the Master Schedule (default is this year)"
        )

        psr.add_argument(
            "-e",
            "--check",
            action="store_true",
            help="Check the current fesh2 status. Shows the status of schedule files and when schedule servers were "
            "last queried.",
        )

        psr.add_argument(
            "--monit",
            action="store_true",
            default=False,
            help="Similar to --check but text output format is intended for a FS monit interface",
        )

        psr.add_argument(
            "-q",
            "--quiet",
            action="store_true",
            help="Runs fesh2 with all terminal output suppressed. Useful when running fesh2 as a service.",
        )

        return psr

    def station_label(self, station_name_2ch):
        """
        Used by Args class to check format of station ID strings
        :param station_name_2ch: station ID (punctuation etc will be removed)
        :type station_name_2ch: string
        :return: string, hopefully lower-case 2-letter code
        :rtype: string
        """
        station_name_2ch = station_name_2ch.strip(string.punctuation).lower()
        if len(station_name_2ch) != 2:
            msg = 'Station name length wrong: "{}". Should be two characters.'.format(
                station_name_2ch
            )
            raise configargparse.ArgumentTypeError(msg)
        return station_name_2ch

    def _str2bool(self, v):
        if isinstance(v, bool):
            return v
        if v.lower() in ("yes", "true", "t", "y", "1"):
            return True
        elif v.lower() in ("no", "false", "f", "n", "0"):
            return False
        else:
            raise configargparse.ArgumentTypeError("Boolean value expected.")


class CustomConfigParser(object):
    """Used by ConfigParser to read the skedf.ctl file"""

    def __init__(self, *args, **kwargs):
        super(CustomConfigParser, self).__init__(*args, **kwargs)

    def parse(self, stream):
        items = OrderedDict()
        for i, line in enumerate(stream):
            line = line.strip()
            # print(line)
            if not line or line[0] in ["*"]:
                # a comment or empty line
                continue
            space_and_comment_regex = r"(?P<space_comment>\!\s*.*)*"
            if line[0] in ["$"]:
                # A key match
                key_regex = r"\$(?P<key>.*)"
                key_match = re.match(key_regex + space_and_comment_regex + "$", line)
                if key_match:
                    key = key_match.group("key")
                    value = ""
                    items[key] = value.strip()
                    continue
            else:
                # its a value
                if key in ["catalogs", "schedules", "snap", "proc", "scratch"]:
                    # these have single values
                    value_regex = r"^\s*(?P<value>.+?)" + space_and_comment_regex + "$"
                    value_match = re.match(value_regex, line)
                    value = value_match.group("value")
                    items[key] = value.strip()
                    continue
                if key in ["print", "misc"]:
                    # these classify multiple key/value pairs
                    white_space = r"\s*"
                    key_val_regex = r"^\s*(?P<key>\w*)\s*(?P<value>.*?)"
                    match = re.match(
                        key_val_regex + space_and_comment_regex + "$", line
                    )
                    if match:
                        sub_key = match.group("key")
                        value = match.group("value")
                        newkey = "{}.{}".format(key, sub_key)
                        # if not items[newkey]:
                        #     items[newkey] = OrderedDict()
                        items[newkey] = value.strip()
                        continue
            raise "Unexpected line {} in {}: {}".format(
                i, getattr(stream, "name", "stream"), line
            )
        return items
