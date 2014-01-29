# cython: profile=False

from cpython cimport Py_XINCREF, Py_XDECREF
from cpython.ref cimport PyObject
from libc.stdlib cimport calloc, free


cdef class State(object):
    def __cinit__(State self, int length):
        self.length = length
        self._store = <PyObject **>calloc(length, sizeof(PyObject *))

    def __len__(State self):
        return self.length

    def __dealloc__(State self):
        cdef int i = 0

        if self._store != NULL:
            for i in range(self.length):
                Py_XDECREF(self._store[i])
            free(self._store)

    def __iter__(State self):
        cdef int i
        cdef object property

        for i in range(self.length):
            property = self.get(i)
            if property is not None:
               yield i, self.get(i)

    cdef object get(State self, int i):
        if not (0 <= i < self.length):
            raise ValueError('index {} > {}'.format(i, self.length))

        if self._store[i]:
            return <object>self._store[i]

        return None

    cdef void put(State self, int i, object value):
        if not (0 <= i < self.length):
            raise ValueError('index {} > {}'.format(i, self.length))

        Py_XINCREF(<PyObject *>value)
        Py_XDECREF(self._store[i])

        self._store[i] = <PyObject *>value

    cdef void merge(State self, State other):
        cdef int i = 0
        cdef object property

        assert self.length == other.length

        for i in range(self.length):
            property = other.get(i)
            if property is not None:
                self.put(i, property)


cdef class Entity(object):
    def __cinit__(State self, int pvs, int index, int serial, int cls, State state):
        self.pvs = pvs
        self.index = index
        self.serial = serial
        self.cls = cls
        self.state = state
