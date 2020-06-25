#!/usr/bin/env python3
from datetime import datetime, timedelta

class Session:
    def __init__(self, s, year):
        d = s.strip(' \n|').split('|')
        self.name = d[0].strip()
        self.code = d[1].strip().lower()

        self.start = datetime.strptime("%d %s %s" % (year, d[2], d[4]), "%Y %b%d %H:%M")
        self.end = self.start + timedelta(0, int(d[5]) * 60 * 60, 0)

        sts = d[6].split(' ')
        self.stations = set()
        sin = sts
        if len(sts) > 1:
            sin = sts[0]

        for i in range(int(len(sin) / 2)):
            self.stations.add(sin[2 * i:2 * i + 2].lower())

        self.stations_removed = set()
        if len(sts) > 1:
            sout = sts[1].strip('-')
            for i in range(int(len(sout) / 2)):
                self.stations_removed.add(sout[2 * i:2 * i + 2].lower())

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

