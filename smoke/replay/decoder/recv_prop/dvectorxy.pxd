import math

from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport dfloat as dcdr_flt


cpdef VectorXYDecoder mk(object prop)


cdef class VectorXYDecoder(abstract.AbstractDecoder):
    cdef public object decoder

    cpdef object decode(VectorXYDecoder self, generic.Stream stream)
