# cython: profile=False

import io

from smoke.io cimport peek as io_pk
from smoke.io cimport util as io_utl


cdef class Wrap(object):
    def __init__(Wrap self, data, tick=0):
        self.handle = io.BytesIO(data)
        self.tick = tick

    cpdef io_pk.Peek read(self):
        cdef object handle = self.handle
        cdef int kind = io_utl.read_varint(handle)
        cdef int size = io_utl.read_varint(handle)
        cdef str message = self.handle.read(size)

        return io_pk.Peek(False, True, kind, self.tick, size, message)
