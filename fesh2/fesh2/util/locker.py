import errno
import fcntl
import os
import time
import logging

logger = logging.getLogger(__name__)


class Locker:
    """Manage the lock file which prevents race conditions

    If there are multiple instances of a program then they could potentially download
    or process schedule files at the same time. This prevents that from happening

    Usage
    -----
    # initialise
    locker = Locker()
    # open the lock file
    if locker.open():
        # lock out everyone else, waiting if necessary for other activity to finish (blocking)
        locker.lock()
        # Do something to the schedule file(s)
        do_something()
        # Signal that we're finished
        locker.unlock()
        # close the file handle
        locker.close()
    else:
        print("Failed to open lock file")
    """

    def __init__(self, filename: str = "/tmp/lockfile_{}.lock".format(__name__)):
        """Initialise: open lock file, set read/write permissions"""
        # location of the lock file
        self.lock_file = filename
        self.lock_fh = None

    def open(self) -> bool:
        """Open the lock file. Must be done first

        Returns
        -------
        object
            True if file was opened and permissions set

        """

        # open the file in append mode
        try:
            self.lock_fh = open(self.lock_file, "a")
        except:
            logger.error(
                "Could not open the lock the lockfile {}".format(self.lock_file)
            )
            return False

        # change permissions so anyone can read/write
        try:
            os.chmod(self.lock_file, 0o0666)
        except:
            logger.error(
                "Could not set permissions of the lockfile {}".format(self.lock_file)
            )
            return False

        return True

    def lock(self):
        """Attempt to lock out the file. Waits indefinitely

        Returns
        -------

        """
        # wait time in sec
        wait_time = 10
        logger.debug("Attempting to lock the lock file")
        while True:
            try:
                fcntl.flock(self.lock_fh, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except IOError as e:
                if e.errno != errno.EAGAIN:
                    raise
                else:
                    logger.warning(
                        "Another instance of this software is accessing files. Waiting "
                        "for it to complete. "
                        "Will check again in {} sec".format(wait_time)
                    )
                    time.sleep(wait_time)

    def unlock(self):
        """Unlock the file so other fesh2 processes can manipulate schedule files etc

        """

        logger.debug("Unlocking the lock file")
        fcntl.flock(self.lock_fh, fcntl.LOCK_UN)

    def close(self):
        """Close the lockfile
        """
        self.lock_fh.close()