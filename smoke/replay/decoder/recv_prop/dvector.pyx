# cython: profile=False

import math

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport dfloat

from smoke.model.dt.const import Flag


cdef class Decoder(abstract.Decoder):
    def __init__(Decoder self, object prop):
        abstract.Decoder.__init__(self, prop)
        self.decoder = dfloat.Decoder(prop)
        self.normal = prop.flags & Flag.Normal

    cpdef object decode(Decoder self, io_strm_gnrc.Stream stream):
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
