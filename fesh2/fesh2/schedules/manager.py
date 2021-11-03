#!/usr/bin/env python3
import datetime
import filecmp
import logging
import os
import shutil
import time
from datetime import datetime, timedelta
from os import path

from fesh2.schedules import server
from fesh2.notifications import Notifications

# from schedules import server
# from notifications import Notifications

logger = logging.getLogger(__name__)


def read_master(files: list, year: int, stations: list) -> list:
    """
    Reads a list of master files and returns an array of sessions sorted by start time

    :param files: An array of filenames (including full path)
    :type files: list
    :param year: the year of the master schedule(s)
    :type year: int
    :param stations: A list of stations (2-letter codes) to process
    :type stations: list
    :return: lis, a list of sessions sorted by start time
    :rtype: an array of sessions from the Session class (see manager.py)
    """

    # make the list of stations a set
    stns = set(stations)
    # this will contain a list of sessions
    sessions_queue_ses = []
    for file in files:
        # read each master file in turn
        with open(file, mode="r") as fd:
            # read a line at a time
            for line in fd.readlines():
                if line.startswith("|"):
                    # line starts with a |, so it's a session
                    # read it:
                    ses = ReadSessionLine(line, year)
                    # if any of our selected stations is in the session, tag it in ses.our_stns_in_exp
                    ses.our_stns_in_exp = stns.intersection(ses.stations)
                    # add the session to the list
                    sessions_queue_ses.append(ses)
    # sort the sessions by start time
    lis = sorted(sessions_queue_ses, key=lambda i: i.start)
    return lis


class Session:
    def __init__(self):
        pass


class ReadSessionLine:
    def __init__(self, line: str, year: int):
        d = line.strip(" \n|").split("|")
        self.name = d[0].strip()
        self.code = d[1].strip().lower()

        logger.debug(f"Master file line: {d}")
        self.start = datetime.strptime("%d %s %s" % (year, d[2], d[4]), "%Y %b%d %H:%M")
        self.end = self.start + timedelta(0, int(float(d[5])) * 60 * 60, 0)

        sts = d[6].split(" ")
        self.stations = set()
        sin = sts
        if len(sts) > 1:
            sin = sts[0]

        for i in range(int(len(sin) / 2)):
            self.stations.add(sin[2 * i : 2 * i + 2].lower())

        self.stations_removed = set()
        if len(sts) > 1:
            sout = sts[1].strip("-")
            for i in range(int(len(sout) / 2)):
                self.stations_removed.add(sout[2 * i : 2 * i + 2].lower())

        self.scheduler = d[7]
        self.correlator = d[8]
        self.status = d[9]
        self.pf = d[10]
        self.dbc = d[11]
        self.submit = d[12]
        self.delay = d[13]
        if len(d) >= 15:
            self.mk4num = d[14]
        else:
            self.mk4num = 0

        self.our_stns_in_exp = []


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
        logger.info(
            "Checking IVS 24h session Master File master{:02d}.txt".format(
                cnf.year - 2000
            )
        )
        local_file = "{}/master{:02d}.txt".format(cnf.SchedDir, cnf.year - 2000)
    else:
        logger.info(
            "Checking IVS Intensive session Master File master{:02d}-int.txt".format(
                cnf.year - 2000
            )
        )
        local_file = "{}/master{:02d}-int.txt".format(cnf.SchedDir, cnf.year - 2000)
    logger.debug("Local file is {}".format(local_file))
    timed_out = check_file_timeout(cnf.MasterCheckTime, local_file)
    file_exists = path.exists(local_file)
    if timed_out or not file_exists or cnf.force_master_update:
        # we've waited long enough or the file doesn't exist locally or a download has been forced
        if timed_out:
            logger.info("It's been longer than the Master schedule check interval")
        if not file_exists:
            logger.info("File doesn't exist locally")
        if cnf.force_sched_update:
            logger.info("A download has been forced")
        # for each server, try to retrieve the file
        master_server = server.MasterServer(cnf.SchedDir)
        master_server.curl_setup(
            cnf.NetrcFile, cnf.CookiesFile, cnf.CurlSecLevel1, cnf.quiet
        )
        force = cnf.force_master_update
        for server_url in cnf.Servers:
            logger.info("Checking Master file(s) at {}".format(server_url))
            (success, new_sched) = master_server.get_master(
                server_url, cnf.year, cnf.SchedDir, force, 0, intensive, cnf.quiet
            )
            if force and success and new_sched:
                # We had a forced download and got the file. Now we only need to download from another server if it's
                # newer there. So set the force flag to False.
                force = False
        master_server.curl_close()
    else:
        logger.info(
            "Less than {} h since the file was last checked. Skipping".format(
                cnf.MasterCheckTime
            )
        )

    return new_sched


def send_warning_new_sched(backup_f, current_f, new_f, config, ses):
    """A new schedule file has been downloaded but not drudged. A backup of the
    previous version has been made, but it also exists with its original
    name. The new schedule is called new_f and should be drudged if it is to
    be used. To drudg the new file by hand:
        mv file.skd.new file.skd
        drudg file.skd
    Or force fesh2 to update the schedules with the following command:
        fesh2 --update --once --DoDrudg -g <session_name>
    where <session_name> is the code for the session to be updated (e.g. r4951)

    The backed-up original file is called backup_f

    :param backup_f:
    :type backup_f: string
    :param current_f:
    :type current_f: string
    :param new_f:
    :type new_f: string
    :return:
    :rtype:
    """
    msg = """
A new schedule file has been downloaded but not drudged. A backup of the 
previous version has been made, but it also exists with its original
name. The new schedule is called {} and should be drudged if it is to
be used. To drudg the new file by hand:

        mv {} {}
        drudg {}

Or force fesh2 to update the schedules with the following command:

    fesh2 --update --once --DoDrudg -g {}

where <session_name> is the code for the session to be updated (e.g. r4951)

The backed-up original file is called {}""".format(
        new_f, new_f, current_f, current_f, ses.code, backup_f
    )
    logger.warning(msg)
    subject = "[Fesh2] The schedule {} needs processing".format(ses.code)
    msg_html = f"""
    <html>

        <head>
            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <title>{subject}</title>
            <meta name="description" content="An interactive getting started guide for Brackets.">
            <link rel="stylesheet" href="main.css">
        </head>
        <body>
            <h1>{subject}</h1>
            <p>
            A new schedule file has been downloaded but not drudged. A backup of the 
    previous version has been made, but it also exists with its original
    name. The new schedule is called <code>{new_f}</code> and should be drudged if it is to
    be used. To drudg the new file by hand:
                <br>
                <blockquote>
    <code>
            mv {new_f} {new_f}<br>
            drudg {current_f}<br>
    </code>
            </blockquote>

    Or force fesh2 to update the schedules with the following command:
                <br>
                <blockquote>
    <code>
        fesh2 --update --once --DoDrudg -g {ses.code};
    </code>
            </blockquote>
    <br>
                <br>
    The backed-up original file is called <code>{current_f}</code>
            <br><br>
            <hr>
            This message was automatically generated and sent by fesh2
            </p>

        </body>
    </html>"""

    if config.EmailNotifications:
        # Send an email too:
        notify = Notifications(
            config.EmailServer,
            config.EmailSender,
            config.EmailRecipients,
            smtp_port=config.SMTPPort,
            server_password=config.EmailPassword,
        )
        notify.send_email(subject, msg, msg_html)


def check_sched(ses, config):
    """
    For a given session, decides if the schedule file needs checking,
    interrogates the server(s) and gets the most
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
    # Change this to false if there's a new schedule file because the user should check
    # and drudg by hand.
    ok_to_drudg = True
    # Is the session current, the next one, or a specific one?
    if not config.check:
        logger.info(
            "Session: {}. Start {}, Stop {}, Stations: {}".format(
                ses.code, ses.start, ses.end, " ".join(sorted(ses.stations))
            )
        )
    if ses.start <= now < ses.end:
        # it's on now
        logger.debug("This session is currently running")
    elif ses.start >= now:
        # it's in the future
        logger.debug("This session is in the future")

    # set up for Schedule File operations
    if not config.check:
        logger.info(
            "Getting schedule file for {} if it's available...".format(ses.code)
        )
    # For each schedule type, go through the servers and check for them if they haven't
    sched_server = server.SchedFileServer(config.SchedDir)
    sched_server.curl_setup(
        config.NetrcFile, config.CookiesFile, config.CurlSecLevel1, config.quiet
    )
    # do we have either a vex or skd file locally? If yes, then just check that type
    (got_sched_file, sched_type) = sched_server.check_exists_sched(ses.code, config)
    types = []

    if got_sched_file:
        # we have a local copy (downloaded previously), so just check this type
        types.append(sched_type)
    else:
        # we don't have any local files, so check all types
        types = config.SchedTypes
    # now go through the valid different types
    logger.debug("Checking file types {}".format(types))
    for type in types:
        # name of the local file:
        local_file = "{}/{}.{}".format(config.SchedDir, ses.code, type)
        logger.debug("Local file is {}".format(local_file))
        timed_out = check_file_timeout(config.ScheduleCheckTime, local_file)

        # If we just want a status report, don't access the servers:
        if not config.check:
            backup_file_name = ""
            file_exists = path.exists(local_file)
            if file_exists:
                # A local copy of the schedule file already exists
                # Make a backup copy of it
                bf = BackupFile()
                backup_file_name = bf.backup_file(local_file)
            if timed_out or not file_exists or config.force_sched_update:
                # we've waited long enough or the file doesn't exist locally or a download
                # has been forced
                if timed_out:
                    logger.info("It's been longer than the schedule check interval")
                if not file_exists:
                    logger.info("File doesn't exist locally")
                if config.force_sched_update:
                    logger.info("A download has been forced")
                # for each server, try to retrieve the file
                force = config.force_sched_update
                for server_url in config.Servers:
                    # get the schedule. Set check_delta_hours=0 to make sure we get the latest version
                    # regardless of server
                    (
                        got_sched_file_from_server,
                        new_from_server,
                    ) = sched_server.get_sched(
                        server_url,
                        ses.code,
                        type,
                        config.year,
                        config.SchedDir,
                        force,
                        config.quiet,
                        check_delta_hours=0,
                    )
                    if force and got_sched_file_from_server and new_from_server:
                        # We had a forced download and got the file. Now we only need to download
                        # from another server if it's newer there. So set the force flag to False.
                        force = False
                    if got_sched_file_from_server:
                        got_sched_file = True
                    if new_from_server:
                        new = True
                # We've been through all the servers
                # did we get a file and is it new and did we have a previous version?
                if got_sched_file and new and file_exists:
                    if not config.update:
                        # We think, based on the file mod times on the server and locally,
                        # that there's a new schedule file called <sched>.skd that's newer
                        # than the backup, called <sched>.skd.bak.N. However, sometimes the mod
                        # time is unreliable (have seen this on curl FILETIME requests for CDDIS).
                        # So do a secondary check where we compare file contents. If they are identical
                        # then it isn't a new file and the backup file should be renamed to <sched>.skd.
                        # Else all is well
                        if filecmp.cmp(local_file, backup_file_name, shallow=False):
                            if config.force_sched_update:
                                logger.info(
                                    "The newly downloaded file is identical in content to the one we "
                                    "already have. The forced update was unnecessary."
                                )
                            else:
                                logger.info(
                                    "The newly downloaded file is identical in content to the one we "
                                    "already have. The server may be reporting an incorrect modification "
                                    "time."
                                )
                            shutil.move(
                                backup_file_name, local_file
                            )  # mv <sched.skd.bak.N> <sched.skd>
                            # We shouldn't need to run drudg again.
                            ok_to_drudg = False
                        else:
                            # Tell the user that there's a new schedule file but don't
                            # Drudg it. Call the new one <sched>.new, the old one <sched>
                            # which should be the same as backup_file_name
                            # input("Press [Return] to continue")

                            ok_to_drudg = False
                            new_file_name = "{}.new".format(local_file)
                            shutil.move(
                                local_file, new_file_name
                            )  # mv <sched.skd> <sched.skd.new>
                            shutil.copy2(
                                backup_file_name, local_file
                            )  # cp <sched.skd.bak.N> <sched.skd>
                            send_warning_new_sched(
                                backup_file_name, local_file, new_file_name, config, ses
                            )
                    else:
                        # Update is forced
                        ok_to_drudg = True
                        # if there's a .new file, we don't need it any more
                        new_file_name = "{}.new".format(local_file)
                        if path.exists(new_file_name):
                            os.remove(new_file_name)

                elif file_exists:
                    if not new_from_server:
                        # We didn't get a new schedule file. So remove the backup file
                        if path.exists(backup_file_name):
                            os.remove(backup_file_name)
                    elif path.exists(backup_file_name):
                        logger.info(
                            "Made a backup of the file to {}".format(backup_file_name)
                        )
                elif not file_exists and new and got_sched_file:
                    # File didn't previously exist and we just downloaded it. Tell the user
                    msg = "A new schedule has been downloaded: {}".format(local_file)
                    subject = "[Fesh2] A new schedule has been downloaded"
                    if config.EmailNotifications:
                        # Send an email too:
                        notify = Notifications(
                            config.EmailServer,
                            config.EmailSender,
                            config.EmailRecipients,
                            smtp_port=config.SMTPPort,
                            server_password=config.EmailPassword,
                        )
                        notify.send_email(subject, msg)
            else:
                if not timed_out:
                    logger.info(
                        "It's less than {} h since the last schedule check. Not checking.".format(
                            config.ScheduleCheckTime
                        )
                    )
                # We didn't get a new schedule file. So remove the backup file
                if path.exists(backup_file_name):
                    os.remove(backup_file_name)

            if got_sched_file:
                # Got the file, don't keep looking down the prioritised list of types
                sched_type = type
                break
    sched_server.curl_close()

    if config.update:
        # the --update option was set. This means we force an update to the skd file and drudg
        # if necessary.
        # Do we have the skd file?
        if got_sched_file:
            # if there's a .skd.new file, rename it to .skd
            local_file = "{}/{}.{}".format(config.SchedDir, ses.code, sched_type)
            new_file_name = "{}.new".format(local_file)
            if path.exists(new_file_name):
                logger.info("Making the new schedule file the default")
                shutil.move(new_file_name, local_file)  # mv <sched.skd.new> <sched.skd>
            # the file exists and we can drudg it
            new = True
            ok_to_drudg = True

    return (got_sched_file, new, sched_type, ok_to_drudg)


def check_file_timeout(check_time: float, filename: str) -> bool:
    """
    compare the access time of the file <filename> and the current time. If
    it's more than check_time_h hrs since the last access, return True
    """
    now_s = time.time()
    # get the last file access time (if it exists)
    if path.exists(filename):
        stinfo = os.stat(filename)
        file_access_time_local = stinfo.st_atime
    else:
        file_access_time_local = now_s
    # Should we check?
    timed_out = (now_s - 60 * 60 * check_time) > file_access_time_local
    return timed_out


class BackupFile:
    """Manage backup file naming, creation, removal etc."""

    def __init__(self):
        # file extension
        self.suffix = "bak"

    def backup_file_name(self, name, version):
        """Given a file name and a versio, return the name of
        the corresponding backup file
        :param name: file name
        :type name: string
        :param version:
        :type version: int
        :return: filename
        :rtype: string
        """
        return "{}.{}.{}".format(name, self.suffix, version)

    def backup_file(self, filename: str) -> str:
        """Make a copy of the file and give it a suffix plus version number

        :param filename:
        :type filename: string
        :return:
        :rtype: str


        Parameters
        ----------
        filename
            Full path to the file
        Returns
        -------
            New file name or raise exception if unsuccessful

        """
        from shutil import copy2

        if not path.exists(filename):
            msg = "File to be backed up was not found: {}".format(filename)
            logger.error(msg)
            raise Exception(msg)

        # get a list of files that have the backup file extension, find the highest version number
        version_number = 1
        highest_version = 0
        test_file = self.backup_file_name(filename, version_number)
        while path.exists(test_file):
            highest_version = version_number
            version_number += 1
            test_file = self.backup_file_name(filename, version_number)

        newfile = self.backup_file_name(filename, highest_version + 1)
        copy2(filename, newfile)
        if not path.exists(newfile):
            msg = "Attempt to backup a file failed. Backup file not created. {}".format(
                filename
            )
            logger.error(msg)
            raise Exception(msg)
        else:
            return newfile
