from smoke.io cimport peek as io_pk


cdef class Wrap(object):
    cdef public object handle
    cdef public int tick

    cpdef io_pk.Peek read(self)
