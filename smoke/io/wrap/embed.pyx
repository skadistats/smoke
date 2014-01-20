import io
import snappy
import struct

from smoke.io cimport util as io_utl
from smoke.io.peek import Peek


cpdef EmbedIO mk(str data, tick=0):
    handle = io.BufferedReader(io.BytesIO(data))
    return EmbedIO(handle, tick=tick)


cdef class EmbedIO(object):
    cdef public object handle
    cdef public int tick

    def __init__(EmbedIO self, handle, tick=0):
        self.handle = handle
        self.tick = tick

    def __iter__(EmbedIO self):
        while True:
            try:
                yield self.read()
            except EOFError:
                raise StopIteration()

    cpdef read(self):
        try:
            kind = io_utl.read_varint(self.handle)
            size = io_utl.read_varint(self.handle)
            message = self.handle.read(size)

            assert len(message) == size
        except AssertionError:
            return EOFError()

        return Peek(False, kind, self.tick, size), message
