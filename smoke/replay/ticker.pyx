# cython: profile=False

from smoke.io cimport plexer as io_plxr

from smoke.replay import dispatch as rply_dsptch
from smoke.replay import match as rply_mtch
from smoke.io import const as io_cnst


cdef class Ticker(object):
    def __init__(Ticker self, io_plxr.Plexer plexer, rply_mtch.Match match):
        self.plexer = plexer
        self.match = match

    def __iter__(Ticker self):
        try:
            while True:
                for peek in self.plexer.read_tick():
                    rply_dsptch.dispatch(peek, self.match)

                yield self.match
        except io_cnst.DEMStopEncountered:
            raise StopIteration()
