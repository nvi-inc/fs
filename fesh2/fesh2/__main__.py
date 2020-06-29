#!/usr/bin/env python
from __future__ import print_function

# Inspired by nobs and fesh

import argparse
import datetime
import logging
import os
import sys
import threading
import time
import string

from fesh2.FeshConfig import Config
from fesh2.MasterSession import Session
from fesh2.Drudgery import Drudg
from fesh2 import SchedServer
from os import path
from datetime import datetime, timedelta


# TODO: Test with different Python versions. 2.7.3, 3.2.3 on pcfshb back to v 3.5.3 and v 2.7
# TODO: Test on old versions of Debian: Etch, Wheezy
# TODO: Logging to MAS?

# Defaults
# Name (including full path) to the configuration file
config_filename = '/usr2/control/fesh2.config'
# Name of the log file. Do not include the path as this should be in the config file
log_filename = 'fesh2.log'

def main_task(config):
    """
    When triggered, this will check for master and schedule files and process them with Drudg.

    :param config: Configuration parameters
    :type config: Config Class
    :return: none
    :rtype: none
    """
    # --------------------------------------------------------------------------
    # update local copy of master schedule (optional)

    # config.logger.info("Checking the Master File...")
    if config.config.getboolean('Station', 'GetMaster'):
        new = check_master(config, intensive=False)
    if config.config.getboolean('Station', 'GetMasterIntensive'):
        new = check_master(config, intensive=True)
    # --------------------------------------------------------------------------
    # Read in the Master File
    # Make a list of master files to process
    mstrs = []
    if config.config.getboolean('Station', 'GetMaster'):
        local_file = '{}/master{:02d}.txt'.format(config.config['FS']['sched_dir'], config.year - 2000)
        if path.exists(local_file):
            mstrs.append(local_file)
    if config.config.getboolean('Station', 'GetMasterIntensive'):
        local_file = '{}/master{:02d}-int.txt'.format(config.config['FS']['sched_dir'], config.year - 2000)
        if path.exists(local_file):
            mstrs.append(local_file)
    if not mstrs:
        # No Master files obtained
        msg = "No Master file(s) found. Exiting"
        logging.error(msg)
        raise Exception(msg)

    # list of all sessions in time order
    sessions_queue_ses = read_master(mstrs, config.year, config.stations)
    # which session(s) we process depends on arguments and config
    sessions_to_process = []
    if config.get_session:
        # if args.get is set then we want a specific session regardless of time or anything else
        sessions_to_process = list(filter(lambda i: i.code in config.get_session, sessions_queue_ses))
    else:
        now = datetime.utcnow()
        for ses in sessions_queue_ses:
            if (config.current and (ses.start <= now < ses.end or ses.start >= now)):
                # ifargs.current is set then get the current or next session
                sessions_to_process = [ses]
                # now break out of the for loop
                break
            elif (ses.start <= now < ses.end) or (now <= ses.start < now + timedelta(days=config.sched_look_ahead_time_d)):
                # only consider scheds within the lookahead time
                # If:
                #       1. we don't want a session with all our stations in it AND at least one of our stations in in the session
                #    OR:
                #       2. we want a session with all our stations in it AND this session satisfies that requirement
                #    THEN:
                #       We found it, so stop searching through the master schedule
                if (not config.all_stations and ses.our_stns_in_exp != set()) or (
                        config.all_stations and ses.our_stns_in_exp == set(config.stations)):
                    sessions_to_process.append(ses)
    # sessions_to_process should now be filled

    # If sessions_to_process is not empty then we found a session satisfying the input criteria
    if not sessions_to_process:
        logging.warning("No sessions were found that satisfy the criteria")
    else:
        # Process each session in the list
        for ses in sessions_to_process:
            (got_sched_file, new, sched_type) = check_sched(ses, config)
            # Drudg the schedule
            drudg_session(ses, config, got_sched_file, new, sched_type)

    # If forced downloads were set, unset them now
    if config.force_sched_update:
        logging.info("A forced schedule download was set. This has now been attempted so stopping the force.")
        config.force_sched_update = False
    if config.force_master_update:
        logging.info("A forced Master schedule download was set. This has now been attempted so stopping the force.")
        config.force_master_update = False
    # show a summary of the sessions
    show_summary(config, mstrs, sessions_to_process)

def check_master(cnf, intensive=False):
    """
    Decides if the Master file needs checking, interrogates the server(s) and gets the most recent one if it
    has been updated.

    :param cnf: configuration parameters (from the config file)
    :type cnf: Config class
    :param intensive: Are we looking for an Intensive master file? (default is 24h session filee)
    :type intensive: boolean
    :return: Has a new version been retrieved?
    :rtype: boolean
    """
    new_sched = False
    if not intensive:
        cnf.logger.info("Checking IVS 24h session Master File master{:02d}.txt".format(cnf.year - 2000))
        local_file = '{}/master{:02d}.txt'.format(cnf.config['FS']['sched_dir'], cnf.year - 2000)
    else:
        cnf.logger.info("Checking IVS Intensive session Master File master{:02d}-int.txt".format(cnf.year - 2000))
        local_file = '{}/master{:02d}-int.txt'.format(cnf.config['FS']['sched_dir'], cnf.year - 2000)
    cnf.logger.debug('Local file is {}'.format(local_file))
    now = time.time()
    if path.exists(local_file):
        stinfo = os.stat(local_file)
        file_access_time_local = stinfo.st_atime
    else:
        file_access_time_local = now
    timed_out = (now - 60 * 60 * cnf.master_check_interval) > file_access_time_local
    file_exists = path.exists(local_file)
    if timed_out or not file_exists or cnf.force_master_update:
        # we've waited long enough or the file doesn't exist locally or a download has been forced
        if timed_out:
            cnf.logger.info("It's been longer than the Master schedule check interval")
        if not file_exists:
            cnf.logger.info("File doesn't exist locally")
        if cnf.force_sched_update:
            cnf.logger.info("A download has been forced")
        # for each server, try to retrieve the file
        master_server = SchedServer.MasterServer(cnf.config['FS']['sched_dir'])
        master_server.curl_setup(cnf.config['Curl']['netrc_file'], cnf.config['Curl']['cookie_file'])
        force = cnf.force_master_update
        for server_url in cnf.servers:
            cnf.logger.info("Checking Master file(s) at {}".format(server_url))
            (success, new_sched) = master_server.get_master(server_url, cnf.year, cnf.config['FS']['sched_dir'],
                                                            force, 0, intensive)
            if force and success and new_sched:
                # We had a forced download and got the file. Now we only need to download from another server if it's
                # newer there. So set the force flag to False.
                force = False
        master_server.curl_close()
    else:
        cnf.logger.info("Less than {} h since the file was last checked. Skipping".format(cnf.master_check_interval))
    return new_sched

def check_sched(ses, config):
    """
    For a given session, decides if the schedule file needs checking, interrogates the server(s) and gets the most
    recent one if it hasn't been downloaded yet or has been updated.

    :param ses: The session to be processed
    :type ses: Session class
    :param config: configuration parameters (from the config file)
    :type config: Config class
    :return: got_sched_file: Did we get a file?,
    new: Is it new?
    sched_type: file type (vex or skd)
    :rtype: boolean, boolean, string
    """
    now = datetime.utcnow()
    new = False
    got_sched_file = False
    # Is the session current, the next one, or a specific one?
    logging.info("Session: {}. Start {}, Stop {}, Stations: {}".format(ses.code, ses.start, ses.end,
                                                                       " ".join(sorted(ses.stations))))
    if ses.start <= now < ses.end:
        # it's on now
        logging.debug("This session is currently running")
    elif ses.start >= now:
        # it's in the future
        logging.debug("This session is in the future")

    # set up for Schedule File operations
    config.logger.info("Getting schedule file for {} if it's available...".format(ses.code))
    # For each schedule type, go through the servers and check for them if they haven't
    sched_server = SchedServer.SchedFileServer(config.config['FS']['sched_dir'])
    sched_server.curl_setup(config.config['Curl']['netrc_file'],
                            config.config['Curl']['cookie_file'])
    # do we have either a vex or skd file locally? If yes, then just check that type
    (got_sched_file, sched_type) = sched_server.check_exists_sched(ses.code, config)
    types = []
    if got_sched_file:
        # we have a local copy (downloaded previously), so just check this type
        types.append(sched_type)
    else:
        # we don't have any local files, so check all types
        types = config.sched_types
    # now go through the valid different types
    config.logger.debug("Checking file types {}".format(types))
    for type in types:
        # name of the local file:
        local_file = "{}/{}.{}".format(config.config['FS']['sched_dir'], ses.code, type)
        config.logger.debug('Local file is {}'.format(local_file))
        now_s = time.time()
        # get the last file access time (if it exists)
        if path.exists(local_file):
            stinfo = os.stat(local_file)
            file_access_time_local = stinfo.st_atime
        else:
            file_access_time_local = now_s
        # Should we check?
        timed_out = (now_s - 60 * 60 * config.sched_check_interval) > file_access_time_local
        file_exists = path.exists(local_file)
        if timed_out or not file_exists or config.force_sched_update:
            # we've waited long enough or the file doesn't exist locally or a download has been forced
            if timed_out:
                config.logger.info("It's been longer than the schedule check interval")
            if not file_exists:
                config.logger.info("File doesn't exist locally")
            if config.force_sched_update:
                config.logger.info("A download has been forced")
            # for each server, try to retrieve the file
            force = config.force_sched_update
            for server_url in config.servers:
                # get the schedule. Set check_delta_hours=0 to make sure we get the latest version
                # regardless of server
                (got_sched_file_from_server, new_from_server) = sched_server.get_sched(server_url,
                                                               ses.code,
                                                               type,
                                                               config.year,
                                                               config.config['FS']['sched_dir'],
                                                               force,
                                                               check_delta_hours=0)
                if force and got_sched_file_from_server and new_from_server:
                    # We had a forced download and got the file. Now we only need to download from another server if it's
                    # newer there. So set the force flag to False.
                    force = False

                if got_sched_file_from_server:
                    got_sched_file = True
                if new_from_server:
                    new = True
        else:
            if not timed_out:
                config.logger.info("It's less than {} h since the last schedule check. Not checking.".format(config.sched_check_interval))
        if got_sched_file:
            # Got the file, don't keep looking down the prioritised list of types
            sched_type = type
            break
    sched_server.curl_close()

    return (got_sched_file, new, sched_type)

def drudg_session(ses, config, got_sched_file, new, sched_type):
    """
    Runs Drudg on the specified schedule file

    :param ses: The session to be processed
    :type ses: Session class
    :param config: configuration parameters (from the config file)
    :type config: Config class
    :param got_sched_file: Did we get a file?
    :type got_sched_file: boolean
    :param new: Is it a new file?
    :type new: boolean
    :param sched_type: schedule file type (vex or skd)
    :type sched_type: string
    :return: none
    :rtype: none
    """
    if not config.do_drudg or not config.config.getboolean('Drudg', 'do_drudg'):
        logging.info('Drudg will not be run on the schedule file')
    else:
        update_stns = []
        drg = Drudg(config.config['Drudg']['binary'],
                    config.config['FS']['sched_dir'],
                    config.config['FS']['proc_dir'],
                    sched_type,
                    config.config['Drudg']['lst_dir'])

        if not new:
            # Checks came back with no new schedule file or no schedule file at all.
            if not got_sched_file:
                logging.info("There is no schedule file on the server.")
            else:
                logging.info("The local copy of the schedule file hasn't changed.")
                # Has the file been drudged?
                # Look for snp, prc files that are later than the modification time of the schedule file
                for station in ses.our_stns_in_exp:
                    drudge_products_up_to_date = drg.check_drudg_output_time(config.config['FS']['sched_dir'],
                                                                             config.config['FS']['proc_dir'],
                                                                             sched_type,
                                                                             ses.code,
                                                                             station)
                    if not drudge_products_up_to_date:
                        update_stns.append(station)
        else:
            # There's a new schedule file
            for i in ses.our_stns_in_exp:
                update_stns.append(i)
        if update_stns:
            # Run drudg
            # print("Run drudg for these stations: {}".format(update_stns))
            for s in update_stns:
                (o1, o2, o3) = drg.godrudg(s, ses.code, config)
                logging.info("Drudg created the following files: {} {} {}".format(o1, o2, o3))
                # put them in the locations specified by the config file


def show_summary(config, mstrs, sessions_to_process):
    """
    Prints a summary of the status of session processing ro the screen
    :param config: configuration parameters (from the config file)
    :type config: Config class
    :param mstrs: list of master file names (full path)
    :type mstrs: array of strings
    :param sessions_to_process: List of sessions to process
    :type sessions_to_process: Session class
    :return: none
    :rtype: none
    """
    print("--------------------------------------------------------------")
    print(Colour.BOLD + Colour.UNDERLINE + "Schedule Status for {}:".format(
        ", ".join(sorted(config.stations))) + Colour.END + "\n")
    if len(mstrs) > 1:
        print(Colour.UNDERLINE + "Master file versions (UTC of latest version downloaded):" + Colour.END)
    else:
        print(Colour.UNDERLINE + "Master file version (UTC of latest version downloaded):" + Colour.END)
    for m in mstrs:
        stinfo = os.stat(m)
        tvers_txt = time.strftime('%Y-%m-%d %H:%M', time.gmtime(stinfo.st_mtime))
        if "int" in m:
            print("\tIntensive sessions: {}".format(tvers_txt))
        else:
            print("\t24h sessions:       {}".format(tvers_txt))
    print("")
    print(Colour.UNDERLINE + "Sessions:" + Colour.END)
    if not sessions_to_process:
        print("\tNo sessions to process")
    else:
        if len(config.stations) > 1:
            print('Session   Start (UT)         Got         FS files prepared?')
            print('                             schedule?   ', end="")
            for i in config.stations:
                print('{}     '.format(i), end="")
            print("")
            print('-------   ----------------   ---------   ', end="")
            for i in config.stations:
                print('-------', end="")
            print("")
        else:
            print('Session   Start (UT)         Got         FS files')
            print('                             schedule?   prepared?')
            print('-------   ----------------   ---------   ---------')
        for ses in sessions_to_process:
            got_sched = path.exists(
                "{}/{}.{}".format(config.config['FS']['sched_dir'], ses.code, 'skd')) or path.exists(
                "{}/{}.{}".format(config.config['FS']['sched_dir'], ses.code, 'vex'))
            print("{:<7s}   {:<16s}   {:<9s}   ".format(ses.code, ses.start.strftime('%Y-%m-%d %H:%M'),
                                                        yn(got_sched)),
                  end="")
            if len(config.stations) > 1:
                got_snp = {}
                got_prc = {}
                got_lst = {}
                for i in config.stations:
                    if i in ses.our_stns_in_exp:
                        got_snp[i] = path.exists(
                            "{}/{}{}.snp".format(config.config['FS']['sched_dir'], ses.code, i))
                        got_prc[i] = path.exists("{}/{}{}.prc".format(config.config['FS']['proc_dir'], ses.code, i))
                        got_lst[i] = path.exists(
                            "{}/{}{}.lst".format(config.config['Drudg']['lst_dir'], ses.code, i))
                        tmp_txt = "{}".format(yn(got_snp[i] and got_prc[i] and got_lst[i]))
                    else:
                        tmp_txt = "-"
                    print("{:<7s}".format(tmp_txt), end="")
                print("")
            else:
                i = config.stations[0]
                got_snp = path.exists("{}/{}{}.snp".format(config.config['FS']['sched_dir'], ses.code, i))
                got_prc = path.exists("{}/{}{}.prc".format(config.config['FS']['proc_dir'], ses.code, i))
                got_lst = path.exists("{}/{}{}.lst".format(config.config['Drudg']['lst_dir'], ses.code, i))
                print("{}".format(yn(got_snp and got_prc and got_lst)))
                # print("")

        print("")
    print("--------------------------------------------------------------\n")

def yn(a):
    """
    Takes a boolean and returns it as 'yes' or 'no'
    :param a: True or false
    :type a: boolean
    :return: 'Yes' if True, otherwise 'no'
    :rtype: string
    """
    if a:
        return 'Yes'
    else:
        return 'No'

class Colour:
    """
    Defines colours and styles for printing on a terminal
    """
    PURPLE = '\033[95m'
    CYAN = '\033[96m'
    DARKCYAN = '\033[36m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'

def read_master(files, year, stations):
    """
    Reads a list of master files and returns an array of sessions sorted by start time

    :param files: An array of filenames (including full path)
    :type files: array
    :param year: the year of the master schedule(s)
    :type year: int
    :param stations: A list of stations (2-letter codes) to process
    :type stations: array
    :return: lis, a list of sessions sorted by start time
    :rtype: an array of sessions from the Session class (see MasterSession.py)
    """

    # make the list of stations a set
    stns = set(stations)
    # this will contain a list of sessions
    sessions_queue_ses = []
    now = datetime.utcnow()
    for file in files:
        # read each master file in turn
        with open(file, mode="r") as fd:
            for line in fd.readlines():
                if line.startswith('|'):
                    # line starts with a |, so it's a session
                    # read it:
                    ses = Session(line, year)
                    # if any of our selected stations is in the session, tag it in ses.our_stns_in_exp
                    ses.our_stns_in_exp = stns.intersection(ses.stations)
                    # add the sesion to the list
                    sessions_queue_ses.append(ses)
    # sort the sessions by start time
    lis = sorted(sessions_queue_ses, key=lambda i: i.start)
    return lis

class Args:
    """
    This class uses the Python Argparse library to process command-line arguments
    """
    def __init__(self):
        """
        Set up command-line paramaters
        """
        now = datetime.utcnow()
        self.parser = argparse.ArgumentParser(
            description=('Automated schedule file preparation for the current, next or specified session.\n\n'
                         'A check for the latest version of the Master File(s) is done first, but skipped if the\n'
                         'time since the last check is less than a specified amount (configureable on the command\n'
                         'line or in the config file). Similarly, checks on schedule files are only done if the\n'
                         'time since the last check exceeds a specified time.\nChecks can be forced on the command\n'
                         'line.'))
        self.parser.add_argument(
            'stns', nargs='*',
            # default=['hb', 'ke', 'yg', 'ho'],
            type=self.station_label,
            help='Stations to consider (default "hb ke yg ho")')
        self.parser.add_argument('-c', '--config',
                                 default=config_filename,
                                 help='The configuration file to use. (default is {})'.format(config_filename))

        self.parser.add_argument('-g', '--get',
                                 default=None,
                                 help='Just get a schedule for this specified session. Give the name of the session (e.g. r4951).')

        self.parser.add_argument('-t', '--tmaster',
                                 help="Only check for a new master file if the last check "
                                      "was more than this number of hours ago. The default "
                                      "is set in the configuration file.")

        self.parser.add_argument('-s', '--tsched',
                                 help="Only check for a new schedule file (SKD or VEX) if the last check "
                                      "was more than this number of hours ago. The default "
                                      "is set in the configuration file.")

        self.parser.add_argument('-m', '--master-update', action='store_true', default=False,
                                 help='Force a download of the Master Schedule (default = False).')

        self.parser.add_argument('-u', '--sched-update', action='store_true', default=False,
                                 help='Force a download of the Schedules (default = False).')

        self.parser.add_argument('-d', '--no-drudg',
                                 action='store_true', default=False,
                                 help='Force NOT to run Drudg on the downloaded/updated schedules (default = False)')

        self.parser.add_argument('-n', '--current', '--now', action='store_true', default=False,
                                 help='Only process the current or next experiment')

        self.parser.add_argument('-a', '--all', action='store_true',
                                 help='find the experiments with all "stns" in it')

        self.parser.add_argument('-o', '--once', action='store_true', default=False,
                                 help="Just run once then exit, don't go into a wait loop (default = False)")

        self.parser.add_argument('-l', '--lookahead', default=None, type=int,
                                 help='only look for schedules less than this number of days away (default is 7)')

        # self.parser.add_argument('-p', '--tpi-period', default=None, type=int, help="TPI period in centiseconds (0
        # = don't use the TPI Daemon, default). This can be set in the config file.")

        self.parser.add_argument('-y', '--year', default=now.year, type=int,
                                 help='The year of the Master Schedule (default is {})'.format(now.year))

        self.args = self.parser.parse_args()
        if (self.args.stns):
            self.stns = set(self.args.stns)
            print("stns = {}".format(self.stns))

    def station_label(self,str):
        """
        Used by Args class to check format of station ID strings
        :param str: station ID (punctuation etc will be removed)
        :type str: string
        :return: string, hopefully lower-case 2-letter code
        :rtype: string
        """
        str = str.strip(string.punctuation).lower()
        if len(str) != 2:
            msg = 'Station name length wrong: "{}". Should be two characters.'.format(str)
            raise argparse.ArgumentTypeError(msg)
        print("args = {}".format(str))
        return str

def start_thread_main(event, config):
    """
    Set up and start the wait_for_event thread 'sched_check' which does a schedule check when triggered
    by the 'timing_loop' thread

    :param event: When this event is set, a schedule check loop is done or underway
    :type event: threading event
    :param config: configuration parameters (from the config file)
    :type config: Config class
    :return: activated thread
    :rtype: a python threading thread.
    """
    thread = threading.Thread(name='sched_check',
                              target=wait_for_event,
                              args=(event, config))
    thread.start()
    return thread

def start_thread_timing_loop(event_1, event_2, thread, config):
    """
    This thread manages the main_task wait loop. It waits a specified time (the shortest out of the master and schedule file
    check wait times) then triggers a check.

    :param event_1: When this event is set, a schedule check loop is done or underway
    :type event_1: threading event
    :param event_2: When this event is set, the event loop is exited
    :type event_2: threading event
    :param thread: the sched_check thread
    :type thread: a python threading thread
    :param config: configuration parameters (from the config file)
    :type config: Config class
    :return: activated thread
    :rtype: a python threading thread.
    """
    thread_2 = threading.Thread(name='timing_loop',
                                target=set_event_loop,
                                args=(event_1, event_2, thread, config))
    thread_2.start()
    return thread_2

def wait_for_event(event, config):
    """
    Waits for the event to be triggerered, then does a schedule check.
    :param event: When this event is set, a schedule check loop is done or underway
    :type event: threading event
    :param config: configuration parameters (from the config file)
    :type config: Config class
    """
    config.logger.debug('WFE: wait for event')
    event_is_set = event.wait()
    config.logger.debug('WFE event set: {}'.format(event_is_set))
    main_task(config)
    config.logger.debug('WFE: clearing event1...')
    event.clear()

def set_event_loop(event_1, event_2, thread, config):
    """
    Waits a specified time (the shortest out of the master and schedule file
    check wait times) then triggers a schedule check in the other thread.

    :param event_1: When this event is set, a schedule check loop is done or underway
    :type event_1: threading event
    :param event_2: When this event is set, the event loop is exited
    :type event_2: threading event
    :param thread: the sched_check thread
    :type thread: a python threading thread
    :param config: configuration parameters (from the config file)
    :type config: Config class
    """
    while not event_2.isSet():
        # get time to wait until next check from the smallest check interval. Add 30 sec just to make sure we don't
        # under-shoot
        t_wait_h = min([config.sched_check_interval, config.master_check_interval])
        t_wait_s = (t_wait_h * 60 * 60) + 30
        start_time = time.time()
        target_time = start_time + t_wait_s
        barLength = 36
        test = (time.time() >= target_time or event_2.isSet())
        # logging.debug(
        #     "set_event_loop top of wait loop. time.time() = {}, target_time = {}, event2.isSet() = {}, test = {}".format(start_time,target_time,event2.isSet(),test))
        while not test:
            time.sleep(2)
            dt = time.time() - start_time
            if dt < 0:
                dt = 0.0
            frac = dt / t_wait_s
            block = int(round(barLength * frac))

            text = "\rNext check in {} [{}]".format(time.strftime('%H:%M:%S', time.gmtime(t_wait_s - dt)),
                                                    "=" * block + " " * (barLength - block))
            sys.stdout.write(text)
            sys.stdout.flush()
            test_time = time.time()
            test = (test_time >= target_time or event_2.isSet())
            # logging.debug(
            #     "set_event_loop bottom of wait loop. time.time() = {}, target_time = {}, event2.isSet() = {}, test = {}".format(start_time,target_time,event2.isSet(),test))
        print("")
        if event_1.isSet():
            # the check routine is still running, don't tell it to start again
            logging.warning(
                "set_event_loop: not signaling another schedule check as the previous one is still running. ")
        else:
            logging.debug("set_event_loop setting event")
            event_1.set()
            logging.debug("set_event_loop: wait for thread to finish")
            thread.join()
            logging.debug("set_event_loop: thread finished")
            logging.debug("set_event_loop: starting thread1")
            thread = start_thread_main(event_1, config)
            logging.debug("set_event_loop: thread started")

def main():
    """
    Reads command line arguments and the config file, starts logging, does an initial schedule
    check and then starts the two threads that manage the main_task loop to periodically check for
    schedule files and process them with Drudg 
    """
    # --------------------------------------------------------------------------
    # Read command-line arguments
    arg = Args()
#    logging.basicConfig(filename='/usr2/log/test3.log',
#                        filemode='a')
    # --------------------------------------------------------------------------
    # read config file and check it makes sense
    # Config instance
    cnf = Config()
    # Load the config file
    cnf.load(arg)
    # check the config makes sense
    cnf.check()
    # --------------------------------------------------------------------------
    # Set up logging
    log_file_str = '{}/{}'.format(cnf.config['FS']['log_dir'], log_filename)
    format_txt_main = '%(asctime)s.%(msecs)03d - %(levelname)s - %(message)s'
    format_txt_short = "%(asctime)s - %(message)s"
    logging.basicConfig(filename=log_file_str,
                        filemode='a',
                        format=format_txt_main,
                        level=logging.DEBUG,
                        datefmt='%Y-%m-%d %H:%M:%S')

    logging.Formatter.converter = time.gmtime
    cnf.logger = logging.getLogger()
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    #ch.setLevel(logging.DEBUG)
    ch.setFormatter(logging.Formatter(format_txt_short))
    cnf.logger.addHandler(ch)
    print("Writing to log file {}.".format(log_file_str))
    # run an initial update
    main_task(cnf)

    # Finish here if we are running in a one-pass only mode
    if not cnf.run_once:
        # Set up threading
        event1 = threading.Event()
        event2 = threading.Event()
        # Thread1 waits for event1 to set, then runs the schedule check
        thread1 = start_thread_main(event1, cnf)
        # event1.set()
        # Thread2 runs a timing loop to set event2 every (specified) minutes
        # If event2 is set then thread2 should quit
        thread2 = start_thread_timing_loop(event1, event2, thread1, cnf)
