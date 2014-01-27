# cython: profile=False

from smoke.replay cimport handler as rply_hndlr
from smoke.io cimport plexer as io_plxr
from smoke.replay cimport match as rply_mtch

from smoke.io import const as io_cnst


cdef class Ticker(object):
    cdef public io_plxr.Plexer plexer
    cdef public rply_mtch.Match match

    def __init__(self, plexer, match):
        self.plexer = plexer
        self.match = match

    def __iter__(self):
        try:
            while True:
                for peek in self.plexer.read_tick():
                    rply_hndlr.handle(peek, self.match)

                yield self.match
        except io_cnst.DEMStopEncountered:
            raise StopIteration()
