# cython: profile=False

import math

from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport dfloat as dcdr_flt


cpdef VectorXYDecoder mk(object prop):
    return VectorXYDecoder(prop)


cdef class VectorXYDecoder(abstract.AbstractDecoder):
    def __init__(VectorXYDecoder self, object prop):
        abstract.AbstractDecoder.__init__(self, prop)
        self.decoder = dcdr_flt.mk(prop)

    cpdef object decode(VectorXYDecoder self, generic.Stream stream):
        cdef float x = self.decoder.decode(stream)
        cdef float y = self.decoder.decode(stream)

        return x, y
