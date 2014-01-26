

cdef class Wrap(object):
    cdef public object handle
    cdef public int tick

    cpdef tuple read(self)