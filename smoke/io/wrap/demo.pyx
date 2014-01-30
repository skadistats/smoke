# cython: profile=False

import io
import snappy
import struct

from smoke.io cimport peek as io_pk
from smoke.io cimport util as io_utl


cdef int COMPRESSED_MASK = 0b01110000
cdef int LEN_HEADER = 8
cdef int LEN_OFFSET = 4


cdef class Wrap(object):
    def __init__(Wrap self, object handle):
        self.handle = handle

    cpdef int bootstrap(Wrap self) except -1:
        header = self.handle.read(LEN_HEADER)
        offset = self.handle.read(LEN_OFFSET)

        if header != 'PBUFDEM\0':
            raise RuntimeError('header invalid')

        return struct.unpack('I', bytearray(offset))[0]

    cpdef io_pk.Peek read(Wrap self):
        cdef int kind = io_utl.read_varint(self.handle)
        cdef int comp = bool(kind & COMPRESSED_MASK)
        cdef int tick = io_utl.read_varint(self.handle)
        cdef int size = io_utl.read_varint(self.handle)
        cdef str message = self.handle.read(size)

        kind = (kind & ~COMPRESSED_MASK) if comp else kind

        if comp:
            message = snappy.uncompress(message)

        return io_pk.Peek(comp, False, kind, tick, size, message)
