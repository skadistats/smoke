# cython: profile=False

cpdef mk(object demo_io, top_blacklist=?, embed_blacklist=?)


cdef class Plexer(object):
    cdef object demo_io
    cdef object queue
    cdef set top_blacklist
    cdef set embed_blacklist
    cdef object stopped

    cpdef object read(self)

    cpdef object read_tick(self)

    cdef object lookahead(self)
