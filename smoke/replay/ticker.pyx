# cython: profile=False

from smoke.replay cimport handler as rply_hndlr
from smoke.io cimport plexer as io_plxr

from smoke.io import const as io_cnst
from smoke.replay import match as rply_mtch

cpdef mk(io_plxr.Plexer plexer, object match):
    return Ticker(plexer, match)


cdef class Ticker(object):
    cdef public object plexer
    cdef public object match

    def __init__(self, plexer, match):
        self.plexer = plexer
        self.match = match

    def __iter__(self):
        try:
            while True:
                for _, pb in self.plexer.read_tick():
                    rply_hndlr.handle(pb, self.match)

                yield self.match
        except io_cnst.DEMStopEncountered:
            raise StopIteration()
