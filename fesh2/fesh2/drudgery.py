#!/usr/bin/env python3
import logging
import os
import re
import sys
import time
from os import path
import shutil
import pexpect

logger = logging.getLogger(__name__)


class Drudg:
    """Tasks for managing interactions with Drudg"""

    def __init__(self, which_drudg, sched_dir, proc_dir, sched_type, lst_dir, snap_dir):
        """

        :param which_drudg: Location of drudg executable (usually /usr2/fs/bin/drudg)
        :param sched_dir: Where the schedule files are (usually /usr2/sched)
        :param sched_type: Schedule type (VEX or SKD)
        :param lst_dir: Location for the LST file
        """
        # Default timeout time (sec)
        self.timeout_s = 3
        self.drudg_exec = which_drudg
        self.sched_dir = sched_dir
        self.proc_dir = proc_dir
        self.sched_type = sched_type
        self.lst_dir = lst_dir
        self.snap_dir = snap_dir
        pass

    def check_drudg_output_time(
        self, sched_dir, snap_dir, proc_dir, sched_type, code, station
    ):
        """checking if the SNP and PRC files exist and are newer than the schedule file.
        Returns: True if the SNP/PRC files are the same date or later than the SKD
                 False if SKD is newer than SNP/PRC
        :param sched_dir: directory where the schedule files are kept
        :param snap_dir: directory where the snap files are kept
        :param sched_type: Schedule type ('vex' or 'skd')
        :param proc_dir: directory where the procedure files are kept
        :param code: observation code (sched file is <code>.skd or <code>.vex)
        :param station: Two-letter lower-case station abbreviation
        """
        found = True
        location = {}
        directory = {"snp": snap_dir, "prc": proc_dir}
        for extension in ["snp", "prc"]:
            location[extension] = "{}/{}{}.{}".format(
                directory[extension], code, station, extension
            )
            found = path.exists(location[extension]) and found
        # If NOT found then the files don't exist
        if not found:
            return False
        # If found = True then both files exist
        sched_filename = "{}/{}.{}".format(sched_dir, code, sched_type)
        sched_mtime = os.stat(sched_filename).st_mtime
        snp_mtime = os.stat(location["snp"]).st_mtime
        prc_mtime = os.stat(location["prc"]).st_mtime
        if (snp_mtime >= sched_mtime) and (prc_mtime >= sched_mtime):
            # We are up to date
            return True
        else:
            # The schedule file was modified after the SNP and/or PRC file
            return False

    def unexpected_response(self, errtext, child):
        logger.error(errtext)
        child.close()

    def pattern_response(self, child, pattern, expected_index, errmsg):
        try:
            index = child.expect(pattern, timeout=self.timeout_s)
            if index == expected_index:
                return True
            else:
                # unexpected response from Drudg
                self.unexpected_response(errmsg, child)
                return False
        except pexpect.EOF:
            # unexpected response from Drudg
            self.unexpected_response(errmsg, child)
            return False
        except pexpect.TIMEOUT:
            # unexpected response from Drudg
            self.unexpected_response(errmsg, child)
            return False

    def godrudg(self, station, code, conf):
        schedfile = "{}/{}.{}".format(self.sched_dir, code, self.sched_type)
        drudg_exec_txt = "{} {}".format(self.drudg_exec, schedfile)
        logger.info(
            "Running Drudg with '{}' in working directory {}".format(
                drudg_exec_txt, self.sched_dir
            )
        )
        try:
            child = pexpect.spawn(drudg_exec_txt, cwd=self.sched_dir)
        except pexpect.ExceptionPexpect as e:
            logger.error("Problem starting drudg: {}".format(e))
            return False, None, None, None
        except BaseException as e:
            logger.error("Unexpected problem starting drudg: {}".format(e))
            return False, None, None, None

        # Run drudge with the working directory set to sched_dir
        # verbose output for pexpect. Comment to turn off:
        child.logfile = sys.stdout.buffer
        pattern = ["which station .*all\) \? ", "\r\n \?"]

        errmsg = "Expected a prompt for a station name from Drudg, but didn't get it."
        if not self.pattern_response(child, pattern, 0, errmsg):
            return (False, None, None, None)

        child.sendline(station)
        # We have selected a station. Next expected pattern is a ? prompt
        errmsg = "Expected a menu prompt from Drudg, but didn't get it."
        if not self.pattern_response(child, pattern, 1, errmsg):
            return (False, None, None, None)

        # Make SNAP File
        child.sendline("3")
        outfile_snp = self.expect_drudg_prompts(child, conf)
        # Make PRC File. Depending on how skedf.ctl is set up, the user may be prompted for
        # a TPI period and/or a cont cal action
        child.sendline("12")
        outfile_prc = self.expect_drudg_prompts(child, conf)
        # Change output dest
        child.sendline("9")
        child.expect("else enter in filename or PRINT.\r\n", timeout=self.timeout_s)

        outfile_lst = "{}/{}{}.lst".format(self.lst_dir, code, station)
        child.sendline(outfile_lst)
        child.expect("no change")
        child.expect("\r\n")
        child.sendline("")
        child.expect("no change")
        child.expect("\r\n")
        child.sendline("")
        child.expect("no change")
        child.expect("\r\n")
        child.sendline("")
        child.expect(" \?", timeout=self.timeout_s)

        # Summary of SNP file
        child.sendline("5")
        child.expect(" \?", timeout=self.timeout_s)

        child.sendline("0")
        child.expect("DRUDG DONE", timeout=self.timeout_s)

        # Make sure the output files go to the right directories.
        # The LST file should be fine because we specify location during Drudg.
        outfile_snp_target = "{}/{}{}.snp".format(self.snap_dir, code, station)
        shutil.move(outfile_snp, outfile_snp_target)
        outfile_snp = outfile_snp_target
        outfile_prc_target = "{}/{}{}.prc".format(self.proc_dir, code, station)
        shutil.move(outfile_prc, outfile_prc_target)
        outfile_prc = outfile_prc_target
        logger.debug(
            "outfiles = {}, {}, {}".format(outfile_snp, outfile_prc, outfile_lst)
        )

        # set the modification times of the output files to the same as the skd file
        # that way, if a user modifies a skd or prc file, it will be noiced by fesh2
        # and a re-drudge won't be done automatically
        stinfo = os.stat(schedfile)
        modtime = stinfo.st_mtime
        self.set_file_times_anow(outfile_snp, modtime)
        self.set_file_times_anow(outfile_prc, modtime)
        self.set_file_times_anow(outfile_lst, modtime)

        child.close()
        return (True, outfile_snp, outfile_prc, outfile_lst)

    def set_file_times_anow(self, local_file, modTime):
        """Change the access time of the file to now and the modification time to modTime."""
        atime = time.time()
        logger.debug(
            "set_file_times_anow: setting access and mod time for {} to {} and {}".format(
                local_file, atime, modTime
            )
        )
        os.utime(local_file, (atime, modTime))
        return True

    def expect_drudg_prompts(self, child, conf):
        # Looking for a case where we may have to submit a response to a
        # question from Drudg.

        # may return an output file name
        outfile = None

        # Array of possible prompts:
        # TODO: new ones:
        # "Use setup_proc (Yes/No):"
        # "Vdif_single_thread_per_file (Yes/No): "
        prompts = [
            "\r\n \?",
            "purge existing",
            "Enter TPI period in centiseconds",
            "Enter in cont_cal action",
            "Enter in cont_cal_polarity",
            "Enter in vsi_align",
            "Use setup_proc",
            "Vdif_single_thread_per_file ",
        ]
        done = False
        while not done:
            # look for a prompt...
            i = child.expect(prompts, timeout=self.timeout_s)
            # and deal with the output...
            if i == 0:
                # back to the main_task drudg prompt
                done = True
            elif i == 1:
                # Being asked if we want to purge existing output file. Say 'yes'
                # child.expect('Y/N\) \?', timeout=self.timeout_s)
                child.sendline("y")
                # child.expect(' \?', timeout=self.timeout_s)
            elif i == 2:
                # TPI period in centiseconds.
                # child.expect('0 for OFF\): ', timeout=self.timeout_s)
                logger.debug("Sending TPI period {}".format(conf.TpiPeriod))
                child.sendline("{}".format(conf.TpiPeriod))
            elif i == 3:
                # Cont cal action? on or off
                # child.expect('on/off\) ', timeout=self.timeout_s)
                logger.debug("Sending ContCalAction {}".format(conf.ContCalAction))
                child.sendline("{}".format(conf.ContCalAction))
            elif i == 4:
                # Cont cal polarity (0-3 or none)
                # child.expect('none\): ', timeout=self.timeout_s)
                logger.debug("Sending ContCalPolarity {}".format(conf.ContCalPolarity))
                child.sendline("{}".format(conf.ContCalPolarity))
            elif i == 5:
                # For PFB DBBCs" Enter in vsi_align (0,1,none): "
                # child.expect('none\): ', timeout=self.timeout_s)
                logger.debug("Sending VsiAlign {}".format(conf.VsiAlign))
                child.sendline("{}".format(conf.VsiAlign))
            elif i == 6:
                # Use setup_proc : responses are YES, Y or NO, N (case insensitive)
                logger.debug("Sending setup_proc {}".format(conf.SetupProc))
                child.sendline("{}".format(conf.SetupProc))
            elif i == 7:
                # For "Vdif_single_thread_per_file" responses are YES, Y or NO, N (case insensitive)
                logger.debug(
                    "Sending Vdif_single_thread_per_file {}".format(
                        conf.VdifSingleThreadPerFile
                    )
                )
                child.sendline("{}".format(conf.VdifSingleThreadPerFile))

            # look for information from drudg on where the snp or prc files were placed (if they were created):
            match_snp = re.search(
                "From file:\s\S*\sTo\s\S*\s\S*\s(\S*)", str(child.before)
            )
            match_prc = re.search("PROCEDURE LIBRARY FILE\s(\S*)", str(child.before))
            if match_prc or match_snp:
                if match_snp:
                    match = match_snp
                elif match_prc:
                    match = match_prc
                logger.debug("CB = {}\n\n".format(str(child.before)))
                logger.debug("group(1) = {}".format(match.group(1)))
                outfile = re.sub(("\\\\[r|n]"), " ", match.group(1)).strip()
                # if outfile doesn't contain a path then the output directory is the working
                # directory which should be self.sched_dir
                if not "/" in outfile:
                    outfile = "{}/{}".format(self.sched_dir.rstrip("/"), outfile)

        return outfile
