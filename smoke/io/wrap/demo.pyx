import io
import snappy
import struct

from smoke.io cimport util as io_utl
from smoke.io.peek import Peek


COMPRESSED_MASK = 0b01110000
LEN_HEADER = 8
LEN_OFFSET = 4


cpdef DemoIO mk(object handle):
    return DemoIO(handle)


cdef object InvalidHeaderError(RuntimeError):
    pass


cdef class DemoIO(object):
    cdef public object handle

    def __init__(DemoIO self, object handle):
        self.handle = handle

    def __iter__(self):
        while True:
            try:
                yield self.read()
            except EOFError:
                raise StopIteration()

    cpdef int bootstrap(DemoIO self) except -1:
        header = self.handle.read(LEN_HEADER)
        offset = self.handle.read(LEN_OFFSET)
        if header != 'PBUFDEM\0':
            raise InvalidHeaderError('header invalid')

        return struct.unpack('I', bytearray(offset))[0]

    cpdef object read(DemoIO self):
        try:
            kind = io_utl.read_varint(self.handle)
            comp = bool(kind & COMPRESSED_MASK)
            kind = (kind & ~COMPRESSED_MASK) if comp else kind
            tick = io_utl.read_varint(self.handle)
            size = io_utl.read_varint(self.handle)
            message = self.handle.read(size)

            assert len(message) == size

            if comp:
                message = snappy.uncompress(message)
        except AssertionError:
            return EOFError()

        return Peek(comp, kind, tick, size), message
