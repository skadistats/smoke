from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract

from smoke.model.dt.const import Flag


cpdef Int64Decoder mk(object prop)


cdef class Int64Decoder(abstract.AbstractDecoder):
    cdef int bits
    cdef long unsign

    cpdef int decode(Int64Decoder self, generic.Stream stream)
