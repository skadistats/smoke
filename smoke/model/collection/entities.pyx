# cython: profile=False

from cpython cimport Py_XINCREF, Py_XDECREF
from cpython.ref cimport PyObject
from libc.stdlib cimport calloc, free

from collections import defaultdict


cdef int ENTITY_BITS = 11
cdef int ENTITY_LIMIT = 2**ENTITY_BITS


cdef to_e(int index, int serial):
    return (serial << ENTITY_BITS) | index


cdef from_e(int ehandle):
    index = ehandle & ((1 << ENTITY_BITS) - 1)
    serial = ehandle >> ENTITY_BITS

    return index, serial


cdef class Collection(object):
    def __init__(Collection self, object by_index=None):
        self._store = <PyObject **>calloc(ENTITY_LIMIT, sizeof(PyObject *))
        self._by_index = None
        self._by_ehandle = None
        self._by_cls = None

    def __dealloc__(Collection self):
        cdef int i

        if self._store != NULL:
            for i in range(ENTITY_LIMIT):
                Py_XDECREF(self._store[i])
            free(self._store)

    cdef mdl_ntt.Entity get(Collection self, int i):
        if not (0 <= i < ENTITY_LIMIT):
            raise ValueError('index out of bounds'.format(i, ENTITY_LIMIT))

        if self._store[i] == NULL:
            return None

        return <mdl_ntt.Entity>self._store[i]

    cdef put(Collection self, int i, mdl_ntt.Entity entity):
        if not (0 <= i < ENTITY_LIMIT):
            raise ValueError('index out of bounds'.format(i, ENTITY_LIMIT))

        Py_XINCREF(<PyObject *>entity)
        Py_XDECREF(self._store[i])

        self._store[i] = <PyObject *>entity

    cdef delete(Collection self, int i):
        if not (0 <= i < ENTITY_LIMIT):
            raise ValueError('index out of bounds'.format(i, ENTITY_LIMIT))

        Py_XDECREF(self._store[i])

        self._store[i] = NULL

    cdef invalidate_views(Collection self):
        self._by_index = None
        self._by_ehandle = None
        self._by_cls = None

    property by_index:
        def __get__(self):
            if self._by_index is None:
                # FIXME: Generate.
                pass

            return self._by_index

    property by_ehandle:
        def __get__(self):
            if self._by_ehandle is None:
                # FIXME: Generate.
                pass

            return self._by_ehandle

    property by_cls:
        def __get__(self):
            if self._by_cls is None:
                # FIXME: Generate.
                pass

            return self._by_cls
