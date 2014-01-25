from smoke.io.stream cimport generic

from smoke.model.dt.const import Flag
from smoke.replay.decoder.recv_prop cimport abstract


cpdef IntDecoder mk(object prop)


cdef class IntDecoder(abstract.AbstractDecoder):
    cdef int bits
    cdef long eat
    cdef long unsign

    cpdef int decode(IntDecoder self, generic.Stream stream)
