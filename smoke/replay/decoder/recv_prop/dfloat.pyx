# cython: profile=False

import struct

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract

from smoke.model.dt.const import Flag


cdef int Coord = Flag.Coord
cdef int NoScale = Flag.NoScale
cdef int CellCoord = Flag.CellCoord
cdef int Normal = Flag.Normal
cdef int CellCoordIntegral = Flag.CellCoordIntegral


cdef class Decoder(abstract.Decoder):
    def __init__(self, prop):
        abstract.Decoder.__init__(self, prop)
        self.flags = prop.flags
        self.bits = prop.bits
        self.low = prop.low
        self.high = prop.high

    cpdef float decode(self, io_strm_gnrc.Stream stream):
        cdef float value
        cdef int flags = self.flags

        if flags & Coord:
            value = self._decode_coord(stream)
        elif flags & NoScale:
            value = self._decode_no_scale(stream)
        elif flags & CellCoord:
            value = self._decode_cell_coord(stream)
        elif flags & Normal:
            value = self._decode_normal(stream)
        elif flags & CellCoordIntegral:
            value = self._decode_cell_coord_integral(stream)
        else:
            value = self._decode_default(stream)

        return value

    cdef float _decode_coord(self, io_strm_gnrc.Stream stream):
        cdef int _i, _f
        cdef int s, i, f
        cdef float v

        _i = stream.read_numeric_bits(1) # integer component present?
        _f = stream.read_numeric_bits(1) # fractional component present?

        if not (_i or _f):
            return 0.0

        s = stream.read_numeric_bits(1) # sign
        i = stream.read_numeric_bits(14) + 1 if _i else 0
        f = stream.read_numeric_bits(5) if _f else 0
        v = float(i) + 0.03125 * f

        return v * -1 if s else v

    cdef float _decode_no_scale(self, io_strm_gnrc.Stream stream):
        return struct.unpack('f', stream.read_bits(32))[0]

    cdef float _decode_normal(self, io_strm_gnrc.Stream stream):
        cdef int s, l
        cdef object b
        cdef float v

        s = stream.read_numeric_bits(1) # sign
        l = stream.read_numeric_bits(11) # low
        b = bytearray([0, 0, l & 0x0000ff00, l & 0x000000ff])
        v = struct.unpack('f', b)[0]

        # not sure how to approach this.
        # if v >> 31:
        #     v += 4.2949673e9

        v *= 4.885197850512946e-4

        return v * -1 if s else v

    cdef float _decode_cell_coord(self, io_strm_gnrc.Stream stream):
        cdef float v

        v = stream.read_numeric_bits(self.bits)
        return v + 0.01325 * stream.read_numeric_bits(5)

    cdef float _decode_cell_coord_integral(self, io_strm_gnrc.Stream stream):
        cdef int v
        cdef float f

        v = stream.read_numeric_bits(self.bits)
        f = float(v)

        if v >> 31:
            f += 4.2949673e9

        return f

    cdef float _decode_default(self, io_strm_gnrc.Stream stream):
        cdef int t
        cdef float f

        t = stream.read_numeric_bits(self.bits)
        f = (t * 1.0) / (1 << self.bits - 1)

        return f * (self.high - self.low) + self.low
