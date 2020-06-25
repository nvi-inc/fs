#!/usr/bin/env python3
import os
import pexpect
import re
import logging

from os import path
class Drudg:
    """ Tasks for managing interactions with Drudg"""

    def __init__(self, which_drudg, sched_dir, sched_type, lst_dir):
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
        self.sched_type = sched_type
        self.lst_dir = lst_dir
        pass

    def check_drudg_output_time(self, sched_dir, proc_dir, sched_type, code, station):
        """checking if the SNP and PRC files exist and are newer than the schedule file
        :param sched_dir: directory where the schedule files are kept
        :param sched_type: Schedule type ('vex' or 'skd')
        :param proc_dir: directory where the procedure files are kept
        :param code: observation code (sched file is <code>.skd or <code>.vex)
        :param station: Two-letter lower-case station abbreviation
        """
        found = True
        location = {}
        directory = {'snp': sched_dir, 'prc': proc_dir}
        for extension in ['snp', 'prc']:
            location[extension] = '{}/{}{}.{}'.format(directory[extension],code,station,extension)
            found = path.exists(location[extension]) and found
        # If NOT found then the files don't exist
        if not found:
            return False
        # If found = True then both files exist
        sched_filename = "{}/{}.{}".format(sched_dir, code, sched_type)
        sched_mtime = os.stat(sched_filename).st_mtime
        snp_mtime = os.stat(location['snp']).st_mtime
        prc_mtime = os.stat(location['prc']).st_mtime
        if (snp_mtime > sched_mtime) and (prc_mtime > sched_mtime):
            # We are up to date
            return True
        else:
            # The schedule file was modified after the SNP and/or PRC file
            return False

    def godrudg(self,station,code,conf):
        child = pexpect.spawn('{} {}/{}.{}'.format(self.drudg_exec,self.sched_dir,code,self.sched_type))
        # verbose output for pexpect. Comment to turn off:
        # child.logfile = sys.stdout.buffer
        child.expect('\) \? ', timeout=self.timeout_s)

        child.sendline(station)
        child.expect(' \?', timeout=self.timeout_s)

        # Make SNAP File
        child.sendline('3')
        outfile_snp = self.expect_drudg_prompts(child,conf)
        # Make PRC File. Depending on how skedf.ctl is set up, the user may be prompted for
        # a TPI period and/or a cont cal action
        child.sendline('12')
        outfile_prc = self.expect_drudg_prompts(child,conf)
        # Change output dest
        child.sendline('9')
        child.expect('else enter in filename or PRINT.\r\n', timeout=self.timeout_s)

        outfile_lst = '{}/{}{}.lst'.format(self.lst_dir,code,station)
        child.sendline(outfile_lst)
        child.expect('no change')
        child.expect('\r\n')
        child.sendline('')
        child.expect('no change')
        child.expect('\r\n')
        child.sendline('')
        child.expect('no change')
        child.expect('\r\n')
        child.sendline('')
        child.expect(' \?', timeout=self.timeout_s)

        # Summary of SNP file
        child.sendline('5')
        child.expect(' \?', timeout=self.timeout_s)

        child.sendline('0')
        child.expect('DRUDG DONE', timeout=self.timeout_s)

        logging.debug("outfiles = {}, {}, {}".format(outfile_snp,outfile_prc,outfile_lst))

        return(outfile_snp,outfile_prc,outfile_lst)


    def expect_drudg_prompts(self, child, conf):
        # Looking for a case where we may have to submit a response to a
        # question from Drudg.

        # may return an output file name
        outfile = None

        # Array of possible prompts:
        prompts = ['\r\n \?',
                   'purge existing',
                   'Enter TPI period in centiseconds',
                   'Enter in cont_cal action',
                   'Enter in cont_cal_polarity',
                   'Enter in vsi_align']
        done = False
        while not done:
            # look for a prompt...
            i = child.expect(prompts, timeout=self.timeout_s)
            # and deal with the output...
            if i==0:
                # back to the main_task drudg prompt
                done = True
            elif i==1:
                # Being asked if we want to purge existing output file. Say 'yes'
                # child.expect('Y/N\) \?', timeout=self.timeout_s)
                child.sendline('y')
                # child.expect(' \?', timeout=self.timeout_s)
            elif i==2:
                # TPI period in centiseconds.
                # child.expect('0 for OFF\): ', timeout=self.timeout_s)
                child.sendline('{}'.format(conf.tpi_period))
            elif i==3:
                # Cont cal action? on or off
                # child.expect('on/off\) ', timeout=self.timeout_s)
                child.sendline('{}'.format(conf.cont_cal_action))
            elif i==4:
                # Cont cal polarity (0-3 or none)
                # child.expect('none\): ', timeout=self.timeout_s)
                child.sendline('{}'.format(conf.cont_cal_polarity))
            elif i==5:
                # For PFB DBBCs" Enter in vsi_align (0,1,none): "
                # child.expect('none\): ', timeout=self.timeout_s)
                child.sendline('{}'.format(conf.vsi_align))

            # look for information from drudg on where the snp or prc files were placed (if they were created):
            match_snp = re.search('From file\:\s\S*\sTo\s\S*\s\S*\s(\S*)',str(child.before))
            match_prc = re.search('PROCEDURE LIBRARY FILE\s(\S*)',str(child.before))
            if match_prc or match_snp:
                if match_snp:
                    match = match_snp
                elif match_prc:
                    match = match_prc
                logging.debug("CB = {}\n\n".format(str(child.before)))
                logging.debug("group(1) = {}".format(match.group(1)))
                outfile = re.sub(('\\\\[r|n]'),' ',match.group(1)).strip()

        return outfile