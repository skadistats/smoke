# cython: profile=False

import io
import snappy
import struct

from smoke.io cimport util as io_utl
from smoke.io.const import Peek


cpdef EmbedIO mk(str data, int tick=0):
    return EmbedIO(io.BytesIO(data), tick=tick)


cdef class EmbedIO(object):
    def __init__(EmbedIO self, handle, tick=0):
        self.handle = handle
        self.tick = tick

    cpdef object read(self):
        cdef int kind = io_utl.read_varint(self.handle)
        cdef int size = io_utl.read_varint(self.handle)
        cdef str message = self.handle.read(size)

        # assert len(message) == size

        return Peek(False, kind, self.tick, size), message
