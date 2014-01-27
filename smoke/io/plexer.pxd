from smoke.io cimport peek as io_pk
from smoke.io.wrap cimport demo as io_wrp_dm


cdef class Plexer(object):
    cdef io_wrp_dm.Wrap wrap
    cdef object queue
    cdef set top_blacklist
    cdef set embed_blacklist
    cdef object stopped

    cdef io_pk.Peek read(self)

    cdef list read_tick(self)

    cdef object lookahead(self)
