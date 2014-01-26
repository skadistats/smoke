# cython: profile=False

import math

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport dfloat


cdef class Decoder(abstract.AbstractDecoder):
    def __init__(Decoder self, object prop):
        abstract.AbstractDecoder.__init__(self, prop)
        self.decoder = dfloat.Decoder(prop)

    cpdef object decode(Decoder self, io_strm_gnrc.Stream stream):
        cdef float x = self.decoder.decode(stream)
        cdef float y = self.decoder.decode(stream)

        return x, y
