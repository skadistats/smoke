from smoke.io cimport peek as io_pk


cdef class Wrap(object):
    cdef public object handle

    cpdef int bootstrap(Wrap self) except -1

    cpdef io_pk.Peek read(Wrap self)
