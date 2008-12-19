"""GnPltError contains all user defined errors used by GnPlt
"""

class GnPltError(Exception):
    """Base class for exceptions in this module"""
    pass


class RXGError(GnPltError):
    """Class for all errors concerning the RXG files """
    pass

class NonConvergenceError(GnPltError):
    pass

