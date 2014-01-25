from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract


cpdef StringDecoder mk(object prop)


cdef class StringDecoder(abstract.AbstractDecoder):
    cpdef str decode(StringDecoder self, generic.Stream stream)
