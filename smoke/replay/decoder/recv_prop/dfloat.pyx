# cython: profile=False

import struct

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.model.dt cimport prop as mdl_dt_prp
from smoke.replay.decoder.recv_prop cimport abstract


cdef:
    int COORD_INTEGER_BITS = 14
    int COORD_FRACTIONAL_BITS = 5
    int COORD_DENOMINATOR = 1 << COORD_FRACTIONAL_BITS
    float COORD_RESOLUTION = 1.0 / COORD_DENOMINATOR

    int COORD_INTEGER_BITS_MP = 11
    int COORD_FRACTIONAL_BITS_MP_LOWPRECISION = 3
    int COORD_DENOMINATOR_LOWPRECISION = 1 << COORD_FRACTIONAL_BITS_MP_LOWPRECISION
    float COORD_RESOLUTION_LOWPRECISION = 1.0 / COORD_DENOMINATOR_LOWPRECISION

    int NORMAL_FRACTIONAL_BITS = 11
    int NORMAL_DENOMINATOR = (1 << NORMAL_FRACTIONAL_BITS) - 1
    float NORMAL_RESOLUTION = 1.0 / NORMAL_DENOMINATOR


cdef class Decoder(abstract.Decoder):
    def __init__(Decoder self, mdl_dt_prp.Prop prop):
        abstract.Decoder.__init__(self, prop)
        self.flags = prop.flags
        self.bits = prop.bits
        self.low = prop.low
        self.high = prop.high
        self.good = 0
        self.bad = 0

    cpdef float decode(Decoder self, io_strm_gnrc.Stream stream):
        cdef float value
        cdef int flags = self.flags

        if flags & mdl_dt_prp.COORD:
            value = self._decode_coord(stream)
        elif flags & mdl_dt_prp.COORDMP:
            value = self._decode_coord_mp(stream, False, False)
        elif flags & mdl_dt_prp.COORDMPINTEGRAL:
            value = self._decode_coord_mp(stream, False, False)
        elif flags & mdl_dt_prp.COORDMPLOWPRECISION:
            value = self._decode_coord_mp(stream, True, False)
        elif flags & mdl_dt_prp.NOSCALE:
            value = self._decode_no_scale(stream)
        elif flags & mdl_dt_prp.NORMAL:
            value = self._decode_normal(stream)
        elif flags & mdl_dt_prp.CELLCOORD:
            value = self._decode_cell_coord(stream)
        elif flags & mdl_dt_prp.CELLCOORDINTEGRAL:
            value = self._decode_cell_coord_integral(stream)
        else:
            value = self._decode_default(stream)

        return value

    cdef float _decode_coord(Decoder self, io_strm_gnrc.Stream stream):
        cdef:
            bint has_int = stream.read_numeric_bits(1)
            bint has_frc = stream.read_numeric_bits(1)
            bint sign
            int i = 0
            int f = 0
            float v

        if not (has_int or has_frc):
            return 0.0

        sign = stream.read_numeric_bits(1)

        if has_int:
            i = stream.read_numeric_bits(COORD_INTEGER_BITS)

        if has_frc:
            f = stream.read_numeric_bits(COORD_FRACTIONAL_BITS)

        v = i + (<float>f * COORD_RESOLUTION)

        return -v if sign else v

    cdef float _decode_coord_mp(Decoder self, io_strm_gnrc.Stream stream, bint integral, bint low_precision):
        cdef:
            bint in_bounds
            bint sign = 0
            int i = 0
            int f = 0
            float v

        in_bounds = stream.read_numeric_bits(1)

        if integral:
            i = stream.read_numeric_bits(1)
            if i:
                sign = stream.read_numeric_bits(1)
                v = stream.read_numeric_bits((COORD_INTEGER_BITS_MP if in_bounds else COORD_INTEGER_BITS) + 1)
        else:
            i = stream.read_numeric_bits(1)
            sign = stream.read_numeric_bits(1)
            if i:
                i = stream.read_numeric_bits((COORD_INTEGER_BITS_MP if in_bounds else COORD_INTEGER_BITS) + 1)
            f = stream.read_numeric_bits(COORD_FRACTIONAL_BITS_MP_LOWPRECISION if low_precision else COORD_FRACTIONAL_BITS)
            v = i + <float>f * (COORD_RESOLUTION_LOWPRECISION if low_precision else COORD_RESOLUTION)

        return -v if sign else v

    cdef float _decode_no_scale(Decoder self, io_strm_gnrc.Stream stream):
        return <float>struct.unpack('f', stream.read_bits(32))[0]

    cdef float _decode_normal(Decoder self, io_strm_gnrc.Stream stream):
        cdef:
            bint sign = stream.read_numeric_bits(1)
            int l = stream.read_numeric_bits(NORMAL_FRACTIONAL_BITS)
            float v = <float>l * NORMAL_RESOLUTION

        return -v if sign else v

    cdef float _decode_cell_coord(Decoder self, io_strm_gnrc.Stream stream):
        cdef float v = stream.read_numeric_bits(self.bits)
        return v + COORD_RESOLUTION * stream.read_numeric_bits(COORD_FRACTIONAL_BITS)

    cdef float _decode_cell_coord_integral(Decoder self, io_strm_gnrc.Stream stream):
        return <float>stream.read_numeric_bits(self.bits)

    cdef float _decode_default(Decoder self, io_strm_gnrc.Stream stream):
        cdef float v = <float>stream.read_numeric_bits(self.bits) / <float>((1 << self.bits) - 1)
        return v * (self.high - self.low) + self.low
