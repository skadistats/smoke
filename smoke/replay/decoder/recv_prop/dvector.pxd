import math

from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport dfloat as dcdr_flt

from smoke.model.dt.const import Flag


cpdef VectorDecoder mk(object prop)


cdef class VectorDecoder(abstract.AbstractDecoder):
    cdef public object decoder
    cdef int normal

    cpdef object decode(VectorDecoder self, generic.Stream stream)