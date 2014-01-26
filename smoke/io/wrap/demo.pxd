

cdef class Wrap(object):
    cdef public object handle

    cpdef int bootstrap(Wrap self) except -1

    cpdef tuple read(Wrap self)
