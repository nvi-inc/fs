#!/usr/bin/env python3
import sys
from io import BytesIO
import pycurl
import logging
import os
import time
import re
from os import path

def file_progress(download_t, download_d, upload_t, upload_d):
    if download_t > 0:
        progress = download_d / download_t
    elif upload_t > 0:
        progress = upload_d / upload_t
    else:
        return
    barLength = 20  # Modify this to change the length of the progress bar
    status = ""
    if not isinstance(progress, int):
        progress = float(progress)
    if not isinstance(progress, float):
        status = "error: progress var must be float\r\n"
        progress = 0.0
    if progress >= 1.0:
        progress = 1.0
        status = "Done...\r"
    block = int(round(barLength * progress))
    text = "\rPercent: [{}] {:3d}% {}/{} {}".format("=" * block + " " * (barLength - block), int(progress * 100),
                                                    download_d, download_t, status)
    sys.stdout.write(text)
    sys.stdout.flush()


def set_file_times_anow(local_file, modTime):
    """Change the access time of the file to now. This is used to decide if
    the file needs checking the next time this routine is run. Note the
    modification time is kept the same as on the server. The modification time is when the
    contents were last changed."""
    atime = time.time()
    logging.debug("set_file_times_anow: setting access and mod time for {} to {} and {}".format(local_file, atime, modTime))
    os.utime(local_file, (atime, modTime))
    return True


class SchedServer(object):
    """ Tasks common to all interactions with the CDDIS schedule file server"""

    def __init__(self, local_dir):
        self.transfer_done = False
        self.b_obj = BytesIO()
        self.curl = pycurl.Curl()
        self.url_prefix = ''
        self.local_dir = local_dir

    def curl_setup(self, netrc_file, cookie_file):
        logging.debug('Setting up curl....')
        # cookies and username/password
        self.curl.setopt(self.curl.NETRC_FILE, netrc_file)
        self.curl.setopt(self.curl.NETRC, True)  # needed?
        self.curl.setopt(self.curl.COOKIEFILE, cookie_file)
        self.curl.setopt(self.curl.COOKIEJAR, cookie_file)
        # follow redirects
        self.curl.setopt(self.curl.FOLLOWLOCATION, True)

        # we want the date of the file (Unixtime)
        self.curl.setopt(self.curl.OPT_FILETIME, True)

        # Write bytes that are utf-8 encoded
        self.curl.setopt(self.curl.WRITEDATA, self.b_obj)

        # progress callback
        self.curl.setopt(self.curl.NOPROGRESS, False)
        self.curl.setopt(self.curl.XFERINFOFUNCTION, file_progress)

        # give up if can't connect to server in 30 sec
        self.curl.setopt(self.curl.CONNECTTIMEOUT, 30)
        # give up if entire operation takes more than 120 sec
        self.curl.setopt(self.curl.TIMEOUT, 120)

        logging.debug('Curl is configured.')

        return True

    def curl_close(self):
        self.curl.close()

    def get_file_time_server(self, url):
        self.curl.setopt(self.curl.URL, url)
        # we want the date of the file (Unixtime)
        self.curl.setopt(self.curl.OPT_FILETIME, True)
        self.curl.setopt(self.curl.FOLLOWLOCATION, True)
        # Just get the header info, not the actual file
        self.curl.setopt(self.curl.NOBODY, True)
        self.curl.setopt(self.curl.HEADER, True)
        # Perform the request
        logging.info("Requesting file header info...")
        self.curl.perform()
        logging.info("Request for file header info done.")

        # HTTP response code, e.g. 200.
        status = self.curl.getinfo(self.curl.RESPONSE_CODE)
        success = False
        if status == 200 or (300 < status <= 308):
            logging.info("Got file status from the server: {}".format(status))
            success = True
        else:
            logging.error("Failed to get file info from server. URL status = {}".format(status))

        if success:
            size_download = self.curl.getinfo(self.curl.SIZE_DOWNLOAD)
            file_time = self.curl.getinfo(self.curl.INFO_FILETIME)
            logging.debug("dowload size = {}, file time = {}".format(size_download, file_time))
        else:
            file_time = 0
        return success, file_time

    def get_file(self, server_url, filename, local_dir, force, check_delta_hours=1):
        """Download a file from the server

        Parameters
        ----------
        filename : string
            the filename to get, excluding the URL prefix.
        force : bool
            Force a check of the server for a new file
        check_delta_hours : integer
            Skip a check if the file was checked less than check_delta_hours ago

        Returns
        -------
        success: bool
            True if we were able to check the file and download it if it was new
        new: bool
            True if a new file was retrieved
        local_dir: string
            Local directory where the file will go
            :param filename:
            :param check_delta_hours:
            :param force:
            :param local_dir:

        """
        # Initially assume we don't need to download the file
        # Where the file should go on this machine, including the path
        local_file = '{}/{}'.format(local_dir, filename)

        # If we don't have this file, or  force is requested, we just want to download it without running any checks
        if not path.exists(local_file) or force:
            if force:
                logmsg = "Download of {} has been forced.".format(filename)
            else:
                logmsg = "The file {} was not found locally. Forcing a download attempt.".format(filename)
            file_mod_time_local = 0
            download_file = True
        else:
            # We have a local copy.
            # Get the access and modification times of the local file
            stinfo = os.stat(local_file)
            file_access_time_local = stinfo.st_atime
            file_mod_time_local = stinfo.st_mtime
            # date = datetime.utcnow()
            now = time.time()
            logging.debug("We have a local copy of {}".format(local_file))
            if (now - 60 * 60 * check_delta_hours) > file_access_time_local:
                # It's more than check_delta_hours since the last check. Download
                # We should tell the server to send the file only if it's newer
                logmsg = "Setting up transaction to get the file only if it's new"
                self.curl.setopt(self.curl.TIMEVALUE, int(file_mod_time_local))
                self.curl.setopt(self.curl.TIMECONDITION, self.curl.TIMECONDITION_IFMODSINCE)
                download_file = True
            else:
                logmsg = "Less than {} h since last request. Not attempting a download.".format(check_delta_hours)
                download_file = False
        logging.info(logmsg)

        if download_file:
            url = '{}/{}'.format(server_url, filename)
            (success, file_mod_time_server) = self.get_file_server(url, local_file)
            # set it's modification and access times
            if not success:
                logging.warning("Could not get {} from the server".format(filename))
                # Don't update the access time because we couldn't get to the file
                return False, False
            else:
                # either we got a new version or the current local one is the latest
                # if file_mod_time_server is > file_mod_time_local, then it's a new file
                if file_mod_time_server > file_mod_time_local:
                    logging.info("Got a new file from the server")
                    set_file_times_anow(local_file, file_mod_time_server)
                    return True, True
                else:
                    logging.info("We already have the latest version of this file")
                    # only change the access time
                    set_file_times_anow(local_file, file_mod_time_local)
                    return True, False
        return True, False

    def report_file_stats(self):
        size_download = self.curl.getinfo(self.curl.SIZE_DOWNLOAD)
        file_time = self.curl.getinfo(self.curl.INFO_FILETIME)
        logging.debug("download size = {}, file time = {}".format(size_download, file_time))
        return(size_download,file_time)

    def get_file_server(self, url, local_file):
        if 'ftps://' in url:
            url = re.sub('ftps://','ftp://',url)
            self.curl.setopt(self.curl.USE_SSL, True)
            
        self.curl.setopt(self.curl.URL, url)
        # Get the file
        self.curl.setopt(self.curl.NOBODY, False)
        self.curl.setopt(self.curl.HEADER, False)

        # write to a temporary file, keep it if it contains whet we want
        local_file_temp = "{}_temp".format(local_file)
        with open(local_file_temp, mode="wb") as fd:
            self.curl.setopt(self.curl.WRITEDATA, fd)
            logging.info("Requesting file from server at {}...".format(url))
            #            self.curl.setopt(self.curl.VERBOSE, True)
            ret = 0
            try:
                self.curl.perform()
            except pycurl.error as e:
                ret = e.args[0]
                logging.debug("Curl perf exception ret = {}".format(ret))

            logging.info("Request for file completed.")
            fd.close()
            if ret > 0:
                status = ret
            else:
                # HTTP response code, e.g. 200.
                status = self.curl.getinfo(self.curl.RESPONSE_CODE)
            success = False
            if status == 200 or status == 226:
                # 200 = Action successfully completed (FTP) 226 = "Closing data connection. Requested file action
                # successful (for example, file transfer or file abort)." (FTP) Got a file
                logging.debug("Got file from the server. Return status: {}".format(status))
                # delete old file
                if path.exists(local_file):
                    os.remove(local_file)
                # change temporary file name to the correct name
                os.rename(local_file_temp, local_file)
                # Get the content stored in the BytesIO object (in byte characters)
                (size_download,file_time) = self.report_file_stats()
                success = True
            elif status == 213:
                # 213 = "File status" (FTP)
                (size_download,file_time) = self.report_file_stats()
                # file isn't newer but we did get a time
                success = True

            elif status == 304:
                # got an empty file because it hasn't changed
                logging.info("The server file hasn't changed. Return status: {}".format(status))
                # delete temporary file
                file_time = 0
                success = True
            elif status == 28:
                logging.warning("Failed to get file from server due to timeout.")
                file_time = 0
            else:
                logging.warning("Failed to get file from server. Return status = {}".format(status))
                file_time = 0
        # finished with the temporary file now
        if path.exists(local_file_temp):
            os.remove(local_file_temp)

        return success, file_time

class MasterServer(SchedServer):
    """ Managing access to the Master schedule file. Inherits from SchedServer"""

    def __init__(self, local_dir):
        super(MasterServer, self).__init__(local_dir)
        self.url_prefix = 'ivscontrol'
        self.master_file_name = ''
        self.master_file_intensive_name = ''

    def get_master(self, server_url, year, local_dir, force, check_delta_hours=1, intensive=False):
        """Download the master schedule for the specified year (integer)

        Parameters
        ----------
        year : integer
            The year of the master schedule to get
        force : bool
            Force a check of the server for a new file

        Returns
        -------
        success: bool
            True if successful, False if not
        new: bool
            True if the file is new, False if not

        """
        # Work out the name of the master file
        if not intensive:
            self.master_file_name = 'master{:02d}.txt'.format(year - 2000)
        else:
            self.master_file_name = 'master{:02d}-int.txt'.format(year - 2000)
        url = "{}/{}".format(server_url,self.url_prefix)
        (success, new) = super(MasterServer,self).get_file(url, self.master_file_name, local_dir, force, check_delta_hours)
        return success, new

class SchedFileServer(SchedServer):
    """ Managing access to schedule files (SKD or VEX). Inherits from SchedServer"""

    def __init__(self, local_dir):
        """
        https://cddis.nasa.gov/archive/vlbi/ivsdata/aux/<year>/<sess>
        e.g. https://cddis.nasa.gov/archive/vlbi/ivsdata/aux/2020/aua063
        """
        super(SchedFileServer,self).__init__(local_dir)
        self.url_prefix = 'ivsdata/aux'
        self.sched_file_name = ''

    def get_sched(self, server_url, code, sched_type, year, local_dir, force, check_delta_hours=1):
        """Download the schedule for the specified session, year (integer)

        Returns
        -------
        bool
            True if successful, False if not

        """
        # Work out the name of the schedule file
        # self.sched_file_name = '{:04d}/{}'.format(year,code)
        self.sched_file_name = '{}.{}'.format(code, sched_type)
        # URL to the directory containing the schedule file
        url = "{}/{}/{}/{}".format(server_url,self.url_prefix, year, code)
        (success, new) = super(SchedFileServer,self).get_file(url, self.sched_file_name, local_dir, force, check_delta_hours)
        return success, new

    def check_exists_sched(self, code, config):
        """ Given an obs code and directory, look for supported schedule files and return
            True if the file exists and the type (either vex or skd)"""
        for ty in config.sched_types:
            local_file = "{}/{}.{}".format(config.config['FS']['sched_dir'], code, ty)
            if path.exists(local_file):
                return True, ty
        # If we get here then the schedule file wasn't found
        return False, ''

