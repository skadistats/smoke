import math

from smoke.replay.decoder.recv_prop cimport dfloat as dcdr_flt
from smoke.model.dt.prop import Flag


cpdef VectorDecoder mk(object prop):
    return VectorDecoder(prop)


cdef class VectorDecoder(object):
    cdef public object prop
    cdef public object decoder
    cdef int _normal

    def __init__(VectorDecoder self, object prop):
        self.prop = prop
        self.decoder = dcdr_flt.mk(prop)
        self._normal = prop.flags & Flag.Normal

    cpdef object decode(VectorDecoder self, object stream):
        cdef float x = self.decoder.decode(stream)
        cdef float y = self.decoder.decode(stream)

        cdef float f, z
        cdef int sign

        if self._normal:
            f = x * x + y * y
            z = 0 if (f <= 1) else math.sqrt(1 - f)

            sign = stream.read_numeric_bits(1)
            if sign:
                z *= -1
        else:
            z = self.decoder.decode(stream)

        return x, y, z
