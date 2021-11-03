#!/usr/bin/env python
"""Fesh2: Geodetic VLBI schedule file management and processing

Fesh2 provides automated schedule file preparation. It requires an installation of the NASA
Field System (https://github.com/nvi-inc/fs). Fesh2 runs in a terminal window and regularly
checks IVS schedule repositories for new or updated versions of Master files and schedule files
for one or more specified stations. A check for the latest version of the Master file(s) is done
first, but skipped if the time since the last check is less than a specified amount (configurable
on the command line or in the config file). Similarly, checks on schedule files are only done if
the time since the last check exceeds a specified time. If new or updated schedules are found,
they are optionally processed with *Drudg* to produce `snp`, `prc` and `lst` files. By default,
once the files have been checked, fesh2 will provide a summary and then go into a wait state
before carrying out another check. Fesh2 can also be run once for a single check or status
report and not go into a wait state. Multiple instances can be run simultaneously. If drudg
output (`snp` or `prc ` files) have been modified by the user and a new schedule becomes
available , fesh2 will download the file but not overwrite Drudg output, but it will warn the
user.

Fesh2 can be run as a foreground application or as a service in the background.

"""
from __future__ import print_function

import datetime
import logging
import os
import re
import signal
import sys
import threading
import time
from collections import OrderedDict
from datetime import datetime, timedelta
from functools import partial
from os import path

from psutil import process_iter, Process

from fesh2._version import __version__
from fesh2.config import Args, Config
from fesh2.drudgery import Drudg
from fesh2.schedules.manager import (
    read_master,
    check_master,
    check_sched,
    ReadSessionLine,
)
from fesh2.tui import FeshTUI
from fesh2.util.locker import Locker
from fesh2.util.logging import FeshLog
from fesh2.notifications import Notifications

# from _version import __version__
# from config import Args, Config
# from drudgery import Drudg
# from schedules.manager import read_master, check_master, check_sched, ReadSessionLine
# from tui import FeshTUI
# from util.locker import Locker
# from util.logging import FeshLog

logger = logging.getLogger(__name__)

DEBUG = True


def main():
    """Setup configuration and logging, start main threads

    Reads command line arguments and the config file, starts logging, does an initial schedule
    check, then, if this is not a check or monitoring interface request,
        * starts the two threads that manage the main_task loop to periodically check for
          schedule files and process them with Drudg.
    Or, if a monitoring interface is requested,
        * start the text-based UI

    """
    # --------------------------------------------------------------------------
    # Read command-line arguments, config from the config file and env variables
    config_in = Args()
    # --------------------------------------------------------------------------
    # Create a configuration instance and add the parameters from above
    # Config instance
    config = Config()
    # Load in the config
    config.load(config_in)
    # check the config makes sense
    config.check_config()
    # --------------------------------------------------------------------------
    # Set up logging
    level = logging.INFO
    if config.monit:
        level = logging.CRITICAL
    if DEBUG:
        level = logging.DEBUG
    quiet = config.quiet or config.monit
    FeshLog(
        config.LogDir,
        "fesh2.log",
        quiet=quiet,
        level=level,
    )
    logger.info("Fesh2 version {}".format(__version__))
    # --------------------------------------------------------------------------
    # What to do if someone generates a keyboard interrupt
    signal.signal(signal.SIGINT, partial(signal_handler, None, None))
    signal.signal(signal.SIGHUP, partial(signal_handler, None, None))
    # --------------------------------------------------------------------------
    # run an initial update
    main_task(config)
    # --------------------------------------------------------------------------
    # if cnf.monit, start up a text-based interface
    if config.monit:
        # (if cnf.monit is set then cnf.check should also be set)
        config.check = True
        # Text UI setup
        TextUI = FeshTUI(main_task, config, config)
        TextUI.loop.set_alarm_in(0.2, TextUI.animate_progress_bar)
        TextUI.loop.run()  # this will return when the user triggers an exit from the interface
    # --------------------------------------------------------------------------
    # Finish here if we are running in a one-pass only mode
    if (not config.run_once) and (not config.check):
        # We're in an ongoing monitoring mode, so...
        # Set up threading
        event_sched_checker = threading.Event()
        event_quit_timing_loop = threading.Event()
        # thread_sched_checker waits for event_sched_checker to set, then runs the schedule check
        thread_sched_checker = start_thread_main(event_sched_checker, config)
        # If event_quit_timing_loop is set then thread_timing_loop should quit
        thread_timing_loop = start_thread_timing_loop(
            event_sched_checker, event_quit_timing_loop, thread_sched_checker, config
        )
        # Set up so that keyboard interrupts will result in threads being terminated now
        signal.signal(
            signal.SIGINT,
            partial(signal_handler, event_quit_timing_loop, thread_timing_loop),
        )
        signal.signal(
            signal.SIGHUP,
            partial(signal_handler, event_quit_timing_loop, thread_timing_loop),
        )

    logging.shutdown()


def signal_handler(event: threading.Event, thread: threading.Thread):
    """Deals with a keyboard interrupt and ends running threads

    Parameters
    ----------
    event: threading event to set to stop the thread
    thread: the thread to stop
    """
    # see https://stackoverflow.com/questions/1112343/how-do-i-capture-sigint-in-python
    logger.warning("Interrupt sent. Will end threads and exit.")
    if thread:
        event.set()
        logger.warning("Waiting for up to 10 sec for the main thread to finish...")
        thread.join()
        if thread.is_alive():
            logger.warning("Thread is still alive. Exiting anyway.")
        else:
            logger.warning("Thread terminated.")
    logger.warning("Exiting.")
    sys.exit(0)


def start_thread_main(event: threading.Event, config: Config) -> threading.Thread:
    """Set up and start the wait_for_event thread 'sched_check'

    ... where sched_check does a schedule check when triggered
    by the 'timing_loop' thread

    Parameters
    ----------
    event : threading.Event
        When this event is set, a schedule check loop is done or underway
    config : Config
        The FeshConfig:Config class containing configuration parameterss
    Returns
    -------
    thread : threading.Thread
        The thread that has been started
    """

    thread = threading.Thread(
        name="sched_check", target=wait_for_event, args=(event, config)
    )
    thread.start()
    return thread


def start_thread_timing_loop(
    event_sched_check: threading.Event,
    event_time_loop: threading.Event,
    thread_sched_check: threading.Thread,
    config: Config,
) -> threading.Thread:
    """
    This thread manages the main_task wait loop. It waits a specified time (the shortest out of the master and schedule file
    check wait times) then triggers a check.

    :param event_sched_check:
    :type event_sched_check: threading event
    :param event_time_loop:
    :type event_time_loop: threading event
    :param thread_sched_check: the sched_check thread
    :type thread_sched_check: a python threading thread
    :param config: configuration parameters (from the config file)
    :type config: Config class
    :return:
    :rtype: a python threading thread.

    Parameters
    ----------
    event_1
        When this event is set, a schedule check loop is done or underway
    event_2
        When this event is set, the event loop is exited
    thread_sched_check
        the sched_check thread
    config

    Returns
    -------
    thread_time_loop
        activated thread
    """
    thread_time_loop = threading.Thread(
        name="timing_loop",
        target=set_event_loop,
        args=(event_sched_check, event_time_loop, thread_sched_check, config),
    )
    thread_time_loop.start()
    return thread_time_loop


def set_event_loop(
    event_1: threading.Event,
    event_2: threading.Event,
    thread_sched_checker: threading.Thread,
    config: Config,
):
    """Waits a specified time, then triggers a schedule check.

    Fesh2 runs checks of the server(s) at regular time intervals as configured by the user.
    This code will continue to run in an endless loop (unless event_time_loop is set elsewhere),
    waiting the specified time (the shortest out of the master and schedule file
    check wait times), then running a schedule file check, which occurs in main_task and is
    "thread_sched_checker", controlled by start_thread_main.

    Parameters
    ----------
    event_1
        When this event is set, a schedule check loop is done or underway
    event_2
        When this event is set, the event loop is exited (usually triggered by a keyboard interrupt)
    thread_sched_checker
        the sched_check thread
    config
        configuration parameters (from the config file)
    """
    while not event_2.isSet():
        # get time to wait until next check from the smallest check interval. Add 30 sec just to make sure we don't
        # under-shoot
        t_wait_h = min([config.ScheduleCheckTime, config.MasterCheckTime])
        t_wait_s = (t_wait_h * 60 * 60) + 30
        start_time = time.time()
        target_time = start_time + t_wait_s
        barLength = 36
        finished_waiting = time.time() >= target_time or event_2.isSet()
        nwaits = 0
        while not finished_waiting:
            time.sleep(2)
            nwaits += 1
            dt = time.time() - start_time
            if dt < 0:
                dt = 0.0
            frac = dt / t_wait_s
            block = int(round(barLength * frac))

            if not config.quiet:
                text = "\rNext check in {} [{}]".format(
                    time.strftime("%H:%M:%S", time.gmtime(t_wait_s - dt)),
                    "=" * block + " " * (barLength - block),
                )
                sys.stdout.write(text)
                sys.stdout.flush()
            elif nwaits % 15 == 0:
                logger.info(
                    "Next check in {}".format(
                        time.strftime("%H:%M:%S", time.gmtime(t_wait_s - dt))
                    )
                )
            test_time = time.time()
            finished_waiting = test_time >= target_time or event_2.isSet()
        if not config.quiet:
            print("")
        if event_1.isSet():
            # the check routine is still running, don't tell it to start again
            logger.warning(
                "set_event_loop: not signaling another schedule check as the previous one is still running. "
            )
        else:
            if not event_2.isSet():
                # if we want to exit, don't trigger a schedule check
                logger.debug("set_event_loop setting event")
                event_1.set()
                logger.debug("set_event_loop: wait for thread to finish")
                thread_sched_checker.join()
                logger.debug("set_event_loop: thread finished")
                # Start a new schedule checker thread, which will pause until event_sched_check is set again
                logger.debug("set_event_loop: starting thread_sched_checker")
                thread_sched_checker = start_thread_main(event_1, config)
                logger.debug("set_event_loop: thread started")
    logger.debug("Event 2 is set")


def wait_for_event(event: threading.Event, config: Config):
    """
    Waits for the event to be triggerered, then does a schedule check.
    :param event: When this event is set, a schedule check loop is done or underway
    :type event: threading event
    :param config: configuration parameters (from the config file)
    :type config: Config class
    """
    logger.debug("WFE: wait for event")
    event_is_set = event.wait()
    logger.debug("WFE event set: {}".format(event_is_set))
    # run the main task
    main_task(config)
    logger.debug("WFE: clearing event1...")
    event.clear()


def main_task(config: Config) -> bool:
    """Check for master and schedule files and optionally process them with Drudg.

    Parameters
    ----------
    config
        Configuration parameters

    Returns
    -------
    True
        if successful

    Raises
    ------
    RuntimeError
        If no master files found
    """
    # If the option for monit-formatted output has been chosen, set config.check to True,
    # because it's the same except for formatting
    if config.monit:
        config.check = True

    """
    Lock out other fesh2 instances from manipulating files. 
    Wait here until the lock file is unlocked so multiple instances of fesh2 don't
    attempt to drudg files at the same time. Go ahead though if config.check or 
    config.monit are set because they don't change local files.
    """
    lock = Locker()
    if not lock.open():
        raise RuntimeError("Unable to lock out other Fesh2 instances")
    if not config.check:
        lock.lock()

    # --------------------------------------------------------------------------
    if not config.check:
        # update local copy of master schedule (optional) unless we are just
        # after a status report.
        if config.GetMaster:
            new = check_master(config, intensive=False)
        if config.GetMasterIntensive:
            new = check_master(config, intensive=True)
    # --------------------------------------------------------------------------
    # Read in the Master Files
    # Make a list() of master files to process
    master_file_names = []
    if config.GetMaster:
        local_file = "{}/master{:02d}.txt".format(config.SchedDir, config.year - 2000)
        if path.exists(local_file):
            master_file_names.append(local_file)
    if config.GetMasterIntensive:
        local_file = "{}/master{:02d}-int.txt".format(
            config.SchedDir, config.year - 2000
        )
        if path.exists(local_file):
            master_file_names.append(local_file)
    if not master_file_names:
        # No Master files obtained
        msg = "No Master file(s) found. Exiting"
        logger.error(msg)
        raise RuntimeError(msg)

    # list of all sessions in time order
    sessions_queue_ses = read_master(master_file_names, config.year, config.Stations)
    # which session(s) we process depends on arguments and config. After this section we'll
    # end up with a list of sessions requiring processing in sessions_to_process
    sessions_to_process = []
    if config.get:
        # if config.get is set then we want a specific session regardless of time or anything else
        sessions_to_process = list(
            filter(lambda i: i.code in config.get, sessions_queue_ses)
        )
    else:
        now = datetime.utcnow()
        for ses in sessions_queue_ses:
            if config.current and (ses.start <= now < ses.end or ses.start >= now):
                # if config.current is set then just get the current or next session
                if suitable_session(config, ses):
                    sessions_to_process = [ses]
                    # now break out of the for loop
                    break
            elif (ses.start <= now < ses.end) or (
                now <= ses.start < now + timedelta(days=config.LookAheadTimeDays)
            ):
                if suitable_session(config, ses):
                    sessions_to_process.append(ses)
    # sessions_to_process should now be filled

    # If sessions_to_process is not empty then we found a session satisfying the input criteria
    if not sessions_to_process:
        logger.warning("No sessions were found that satisfy the criteria")
    else:
        # Process each session in the list
        for ses in sessions_to_process:
            (got_sched_file, new, sched_type, ok_to_drudg) = check_sched(ses, config)
            # got_sched_file is True if we got the file
            # new = True if it's newer than the old one (if there was one)
            if not config.check:
                # Drudg the schedule
                if ok_to_drudg:
                    drudg_session(ses, config, got_sched_file, new, sched_type)
                else:
                    logger.info("Skipping Drudg for this session")

    if not config.check:
        # If forced downloads were set, unset them now
        if config.force_sched_update:
            logger.info(
                "A forced schedule download was set. This has now been attempted so stopping the force."
            )
            config.force_sched_update = False
        if config.force_master_update:
            logger.info(
                "A forced Master schedule download was set. This has now been attempted so stopping the force."
            )
            config.force_master_update = False
    # show a summary of the sessions. Also populates info for the TUI
    show_summary(config, master_file_names, sessions_to_process)
    # Record the time of the last update (only if we're not doing a status check)
    # TODO: change this. Maybe a sqlite database?
    sched_check_text = "** Schedule check completed at {} **\n".format(
        time.strftime("%d %b %Y %H:%M UTC", time.gmtime())
    )
    if not config.check:
        # We'll append the lock file with sched_check_text. This can be read by this or other
        # fesh2 processes to find out when the last schedule file check was done
        # get the current level
        lock.lock_fh.write(sched_check_text)
        lock.lock_fh.flush()
        # lgr = logging.getLogger()
        # llevel = lgr.getEffectiveLevel()
        # # make sure the log level is INFO
        # lgr.setLevel(logging.INFO)
        # # send a message
        # logger.info(sched_check_text)
        # # revert log level
        # lgr.setLevel(llevel)
    else:
        # read the lock file and find the time of the last sched_check_text
        lastfound = None
        with open(lock.lock_file) as fh:
            data = fh.readlines()
            fh.close()
        for line in data:
            if sched_check_text in line:
                lastfound = line
        if lastfound:
            sp = re.split(r"\s|\.", lastfound)
            try:
                dt = datetime.strptime(
                    "{} {}".format(sp[0], sp[1]), "%Y-%m-%d %H:%M:%S"
                )
                delta = (datetime.utcnow() - dt).total_seconds()
                delta_h = int((delta - delta % 3600) / 3600)
                delta_m = int((delta - (3600 * delta_h)) / 60)
                logger.info(
                    "Schedules were last checked {:02d}:{:02d} ago (HH:MM)".format(
                        delta_h, delta_m
                    )
                )
            except:
                logger.warning(
                    "Could not decode lock file to extract last schedule check time"
                )
    # release the lock file and tidy up
    if not config.check:
        lock.unlock()
    lock.close()
    del lock
    return True


def drudg_session(
    ses: ReadSessionLine,
    config: Config,
    got_sched_file: bool,
    new: bool,
    sched_type: str,
):
    """Runs Drudg on the specified schedule file

    Parameters
    ----------
    ses
        The session to be processed
    config
        configuration parameters
    got_sched_file
        Did we get a file?
    new
        Is it a new file?
    sched_type
        schedule file type (vex or skd)

    """
    if not config.DoDrudg:
        logger.info("Drudg will not be run on the schedule file")
    else:

        update_stns = []
        drg = Drudg(
            config.DrudgBinary,
            config.SchedDir,
            config.ProcDir,
            sched_type,
            config.LstDir,
            config.SnapDir,
        )

        if not new:
            # Checks came back with no new schedule file or no schedule file at all.
            if not got_sched_file:
                logger.info(f"There is no schedule file for {ses.code} on the server.")
            else:
                logger.info("The local copy of the schedule file hasn't changed.")
                # Has the file been drudged?
                # Look for snp, prc files that are later than the modification time of the schedule file
                for station in ses.our_stns_in_exp:
                    drudge_products_up_to_date = drg.check_drudg_output_time(
                        config.SchedDir,
                        config.SnapDir,
                        config.ProcDir,
                        sched_type,
                        ses.code,
                        station,
                    )
                    if not drudge_products_up_to_date:
                        update_stns.append(station)
        else:
            # There's a new schedule file
            for i in ses.our_stns_in_exp:
                update_stns.append(i)
        if update_stns:
            # Run drudg
            logger.info(
                "Run drudg for these stations on {}: {} ".format(ses.code, update_stns)
            )
            for s in update_stns:
                (success, o1, o2, o3) = drg.godrudg(s, ses.code, config)
                if success:
                    logger.info(
                        "Drudg created the following files: {} {} {}".format(o1, o2, o3)
                    )
                else:
                    msg = f"Drudg failed for station {s} {ses.code}. Run drudg manually to search for the problem."
                    logger.error(msg)
                    if config.EmailNotifications:
                        # Send an email too:
                        subject = f"[Fesh2] The schedule {ses.code} needs processing"
                        notify = Notifications(
                            config.EmailServer,
                            config.EmailSender,
                            config.EmailRecipients,
                            smtp_port=config.SMTPPort,
                            server_password=config.EmailPassword,
                        )
                        notify.send_email(subject, msg)

def show_summary(config, mstrs, sessions_to_process):
    """
    Prints a summary of the status of session processing to the screen
    :param config: configuration parameters (from the config file)
    :type config: Config class
    :param mstrs: list of master file names (full path)
    :type mstrs: array of strings
    :param sessions_to_process: List of sessions to process
    :type sessions_to_process: Session class
    :return: none
    :rtype: none
    """
    append_reprocess_note = False
    logger.info("-" * 80)

    # If a monit interface has been requested (config.monit=True), then we want to populate the
    # Dictionary config.tui_data with text for the Text User Interface (TUI)

    # Check if fesh2 is running elsewhere, as a service or in a terminal
    my_pid = os.getpid()
    processes_running = {}
    for p in process_iter():
        # make a list of running fesh2 processes
        # if ("fesh2" in p.name() or "python3" in p.name()) and p.pid != my_pid:
        if "fesh2" in p.name() and p.pid != my_pid:
            processes_running[p.pid] = p

    lproc = len(processes_running)
    config.tui_data["processes_warning"] = False
    config.tui_data["processes_list"] = ""

    if lproc == 0:
        txt = "There are no fesh2 processes currently running."
        logger.warning(Colour.RED + txt + Colour.END)
        config.tui_data["processes"] = txt
        config.tui_data["processes_warning"] = True
    else:
        if lproc == 1:
            txt = "There is currently one fesh2 process running"
        else:
            txt = "There are currently {} fesh2 processes running".format(lproc)
            config.tui_data["processes_list"] = "{}:\n".format(txt)
        logger.info(txt)
        config.tui_data["processes"] = txt
        terminal = False
        pids = sorted(processes_running.keys())
        for i in pids:
            p = Process(i)
            if p.terminal():
                terminal = True
            qmode = "--quiet" in " ".join(p.cmdline())
            txt = "  - Process with PID {:5d} is ".format(i)
            if terminal:
                txt += "running in a terminal"
                if qmode:
                    txt += " in quiet mode (no screen output)"
                txt += "."
            else:
                txt += "running in the background."
            logger.info(txt)
            config.tui_data["processes_list"] = "{}:\n".format(txt)
        config.tui_data["processes_list"] = "{}: \n{}".format(
            config.tui_data["processes"], config.tui_data["processes_list"]
        )
    logger.info("")
    txt = "Schedule Status for {}:".format(", ".join(sorted(config.Stations)))
    logger.info(Colour.BOLD + Colour.UNDERLINE + txt + Colour.END)
    config.tui_data["status_station_header"] = txt
    if len(mstrs) > 1:
        txt = "Master file versions (UTC of latest version downloaded):"
    else:
        txt = "Master file version (UTC of latest version downloaded):"
    logger.info(Colour.UNDERLINE + txt + Colour.END)
    config.tui_data["master_header"] = txt

    config.tui_data["master_lines"] = ""
    for m in mstrs:
        stinfo = os.stat(m)
        tvers_txt = time.strftime("%Y-%m-%d %H:%M", time.gmtime(stinfo.st_mtime))
        if "int" in m:
            logger.info("\tIntensive sessions: {}".format(tvers_txt))
            config.tui_data["vartxt_24h"] = tvers_txt
        else:
            logger.info("\t24h sessions:       {}".format(tvers_txt))
            config.tui_data["vartxt_int"] = tvers_txt
    logger.info("")
    logger.info(Colour.UNDERLINE + "Sessions:" + Colour.END)
    txt = ""
    if not sessions_to_process:
        logger.info("\tNo sessions to process")
        config.tui_data["sessions"] = None
    else:
        config.tui_data["sessions"] = OrderedDict()
        if len(config.Stations) > 1:
            logger.info(
                "Session   Start (UT)         Got         Age*    FS files prepared?"
            )
            txt = "                             schedule?   (hrs)   "
            for i in config.Stations:
                txt = "{}{}     ".format(txt, i)
            logger.info(txt)
            txt = "-------   ----------------   ---------   -----   "
            for i in config.Stations:
                txt = "{}-------".format(txt)
            logger.info(txt)
        else:
            logger.info("Session   Start (UT)         Got         Age*   FS files")
            logger.info("                             schedule?   (hrs)  prepared?")
            logger.info("-------   ----------------   ---------   -----  ---------")
        for ses in sessions_to_process:
            txt = ""
            got_sched = False
            got_sched_new = False
            for ext in ("skd", "vex"):
                local_file = "{}/{}.{}".format(config.SchedDir, ses.code, ext)
                if path.exists(local_file):
                    got_sched = True
                    stinfo = os.stat(local_file)
                local_file_new = "{}.new".format(local_file)
                if path.exists(local_file_new):
                    got_sched_new = True

            got_sched_txt_yn = yn(got_sched)
            if got_sched_new:
                got_sched_txt = (
                    "{} ".format(got_sched_txt_yn) + Colour.RED + "**   " + Colour.END
                )
                got_sched_txt_urwid = "{} **".format(got_sched_txt_yn)
                append_reprocess_note = True
                config.tui_data["reprocess_note"] = True
            else:
                got_sched_txt = got_sched_txt_yn
                got_sched_txt_urwid = got_sched_txt_yn

            txt = "{}{:<7s}   {:<16s}   {:<9s}".format(
                txt, ses.code, ses.start.strftime("%Y-%m-%d %H:%M"), got_sched_txt
            )
            if got_sched:
                sched_age_txt = "{:<5d}".format(
                    int((time.time() - stinfo.st_mtime) / 60.0 / 60.0)
                )
                txt = "{}   {}  ".format(txt, sched_age_txt)
            else:
                sched_age_txt = ""
                txt = "{}          ".format(txt)

            prep_txt = ""
            if len(config.Stations) > 1:
                got_snp = {}
                got_prc = {}
                got_lst = {}
                for i in config.Stations:
                    if i in ses.our_stns_in_exp:
                        got_snp[i] = path.exists(
                            "{}/{}{}.snp".format(config.SnapDir, ses.code, i)
                        )
                        got_prc[i] = path.exists(
                            "{}/{}{}.prc".format(config.ProcDir, ses.code, i)
                        )
                        got_lst[i] = path.exists(
                            "{}/{}{}.lst".format(config.LstDir, ses.code, i)
                        )
                        # Just check SNP and PRC file locations. Someone may have moved the LST
                        # file and it's is not critical
                        tmp_txt = "{}".format(yn(got_snp[i] and got_prc[i]))
                    else:
                        tmp_txt = "-"
                    prep_txt = "{}{:<7s}".format(prep_txt, tmp_txt)
            else:
                i = config.Stations[0]
                got_snp = path.exists("{}/{}{}.snp".format(config.SnapDir, ses.code, i))
                got_prc = path.exists("{}/{}{}.prc".format(config.ProcDir, ses.code, i))
                got_lst = path.exists("{}/{}{}.lst".format(config.LstDir, ses.code, i))
                # Just check SNP and PRC file locations. Someone may have moved the LST
                # file and it's is not critical
                prep_txt = "{}".format(yn(got_snp and got_prc))

            logger.info("{}{}".format(txt, prep_txt))
            config.tui_data["sessions"][ses] = [
                ses.code,
                ses.start.strftime("%Y-%m-%d %H:%M"),
                got_sched_txt_urwid,
                sched_age_txt,
                prep_txt,
            ]

        logger.info("")
    logger.info("-" * 80)
    logger.info("[*] Age = time since the schedule file was released.")
    if append_reprocess_note:
        logger.info(
            Colour.RED
            + "[**] A new schedule file has been downloaded but not drudged."
            + Colour.END
            + " A backup of the"
        )
        logger.info(
            "    previous version has been kept, but it also exists with its original"
        )
        logger.info(
            "    name. The new schedule is called <session_code>.skd.new and should be"
        )
        logger.info("    drudged if it is to be used. To drudg the new file by hand:")
        logger.info("        cd {}".format(config.SchedDir))
        logger.info("        mv <session_code>.skd.new <session_code>.skd")
        logger.info("        drudg <session_code>.skd")
        logger.info(
            "    Or force fesh2 to update the schedules with the following command:"
        )
        logger.info("        fesh2 --update --once --DoDrudg -g <session_code>")
        logger.info(
            "    where <session_code> is the code for the session to be updated (e.g. r4951)"
        )
        logger.info(
            "    The backed-up original file is called <session_code>.skd.bak.N"
        )
    logger.info("")
    logger.info(
        "** Status check completed at {} **".format(
            time.strftime("%d %b %Y %H:%M UTC", time.gmtime())
        )
    )

    logger.info("-" * 80)


def yn(state: bool) -> str:
    """
    Takes a boolean and returns it as 'yes' or 'no'
    :param state: True or false
    :type state: boolean
    :return: 'Yes' if True, otherwise 'no'
    :rtype: string
    """
    return "Yes" if state else "No"


def suitable_session(config: Config, ses: ReadSessionLine) -> bool:
    """Logic to determine if the session has the right station(s) in it

    If:
          1. we don't want a session with all our stations in it AND at least one of
          our stations in in the session
       OR:
          2. we want a session with all our stations in it AND this session satisfies
          that requirement
       THEN:
          return True

    Parameters
    ----------
    config
        Fesh2 configuration
    ses
        A Session description from ScheduleManager

    """
    if (not config.all_stations and ses.our_stns_in_exp != set()) or (
        config.all_stations and ses.our_stns_in_exp == set(config.Stations)
    ):
        return True
    else:
        return False


class Colour:
    """Defines colours and styles for printing on a terminal"""

    PURPLE = "\033[95m"
    CYAN = "\033[96m"
    DARKCYAN = "\033[36m"
    BLUE = "\033[94m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"
    END = "\033[0m"


if __name__ == "__main__":
    main()
