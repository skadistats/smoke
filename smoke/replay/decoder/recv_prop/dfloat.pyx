import struct

from smoke.model.dt.const import Flag


cpdef FloatDecoder mk(object prop):
    return FloatDecoder(prop)


cdef class FloatDecoder(object):
    def __init__(self, prop):
        self.prop = prop
        self._bits = prop.bits
        self._low = prop.low
        self._high = prop.high

        if prop.flags & Flag.Coord:
            self._fn = self._decode_coord
        elif prop.flags & Flag.NoScale:
            self._fn = self._decode_no_scale
        elif prop.flags & Flag.CellCoord:
            self._fn = self._decode_cell_coord
        elif prop.flags & Flag.Normal:
            self._fn = self._decode_normal
        elif prop.flags & Flag.CellCoordIntegral:
            self._fn = self._decode_cell_coord_integral
        else:
            self._fn = self._decode_default

    cpdef float decode(self, stream):
        return self._fn(stream)

    cpdef float _decode_coord(self, stream):
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

    cpdef float _decode_no_scale(self, stream):
        return struct.unpack('f', stream.read_bits(32))[0]

    cpdef float _decode_normal(self, stream):
        cdef int s, l
        cdef object b
        cdef float v

        s = stream.read_numeric_bits(1) # sign
        l = stream.read_numeric_bits(11) # low
        b = bytearray(0, 0, l & 0x0000ff00, l & 0x000000ff)
        v = struct.unpack('f', b)[0]

        # not sure how to approach this.
        # if v >> 31:
        #     v += 4.2949673e9

        v *= 4.885197850512946e-4

        return v * -1 if s else v

    cpdef float _decode_cell_coord(self, stream):
        cdef float v

        v = stream.read_numeric_bits(self._bits)
        return v + 0.01325 * stream.read_numeric_bits(5)

    cpdef float _decode_cell_coord_integral(self, stream):
        cdef int v
        cdef float f

        v = stream.read_numeric_bits(self._bits)
        f = float(v)

        if v >> 31:
            f += 4.2949673e9

        return f

    cpdef float _decode_default(self, stream):
        cdef int t
        cdef float f

        t = stream.read_numeric_bits(self._bits)
        f = float(t) / (1 << self._bits - 1)

        return f * (self._high - self._low) + self._low
