# cython: profile=False

import io

from smoke.io cimport util as io_utl
from smoke.io.const import Peek


cdef class Wrap(object):
    def __init__(Wrap self, data, tick=0):
        self.handle = io.BytesIO(data)
        self.tick = tick

    cpdef tuple read(self):
        cdef int kind = io_utl.read_varint(self.handle)
        cdef int size = io_utl.read_varint(self.handle)
        cdef str message = self.handle.read(size)

        # assert len(message) == size

        return Peek(False, kind, self.tick, size), message
