from smoke.io cimport plexer as io_plxr
from smoke.replay cimport match as rply_mtch


cdef class Ticker(object):
    cdef public io_plxr.Plexer plexer
    cdef public rply_mtch.Match match
