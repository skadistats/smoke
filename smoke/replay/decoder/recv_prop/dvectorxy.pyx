import math

from smoke.replay.decoder.recv_prop cimport dfloat as dcdr_flt


cpdef VectorXYDecoder mk(object prop):
    return VectorXYDecoder(prop)


cdef class VectorXYDecoder(object):
    cdef public object prop
    cdef public object decoder

    def __init__(VectorXYDecoder self, object prop):
        self.prop = prop
        self.decoder = dcdr_flt.mk(prop)

    cpdef object decode(VectorXYDecoder self, object stream):
        cdef float x = self.decoder.decode(stream)
        cdef float y = self.decoder.decode(stream)

        return x, y
