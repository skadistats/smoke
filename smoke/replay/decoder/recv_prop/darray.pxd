from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract


cpdef ArrayDecoder mk(object prop, object array_prop_decoder)


cdef class ArrayDecoder(abstract.AbstractDecoder):
    cdef public object decoder
    cdef int bits

    cpdef object decode(ArrayDecoder self, generic.Stream stream)
