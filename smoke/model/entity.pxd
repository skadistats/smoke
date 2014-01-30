from cpython.ref cimport PyObject


cdef enum PVS:
    PRESERVE = 0
    ENTER    = 1
    LEAVE    = 2
    DELETE   = 3


cdef class State(object):
    cdef public int length
    cdef PyObject **_store

    cpdef object get(State self, int i)

    cpdef put(State self, int i, object value)

    cdef void merge(State self, State other)

cdef class Entity(object):
    cdef public int pvs
    cdef public int index
    cdef public int serial
    cdef public int cls
    cdef public State state
