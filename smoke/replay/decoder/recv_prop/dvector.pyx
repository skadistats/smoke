# cython: profile=False

import math

from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport dfloat as dcdr_flt

from smoke.model.dt.const import Flag


cpdef VectorDecoder mk(object prop):
    return VectorDecoder(prop)


cdef class VectorDecoder(abstract.AbstractDecoder):
    def __init__(VectorDecoder self, object prop):
        abstract.AbstractDecoder.__init__(self, prop)
        self.decoder = dcdr_flt.mk(prop)
        self.normal = prop.flags & Flag.Normal

    cpdef object decode(VectorDecoder self, generic.Stream stream):
        cdef float x = self.decoder.decode(stream)
        cdef float y = self.decoder.decode(stream)

        cdef float f, z
        cdef int sign

        if self.normal:
            f = x * x + y * y
            z = 0 if (f <= 1) else math.sqrt(1 - f)

            sign = stream.read_numeric_bits(1)
            if sign:
                z *= -1
        else:
            z = self.decoder.decode(stream)

        return x, y, z
