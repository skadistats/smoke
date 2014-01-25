# cython: profile=False

from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract


cpdef StringDecoder mk(object prop):
    return StringDecoder(prop)


cdef class StringDecoder(abstract.AbstractDecoder):
    def __init__(StringDecoder self, prop):
        abstract.AbstractDecoder.__init__(self, prop)

    cpdef str decode(StringDecoder self, generic.Stream stream):
        cdef int bytelength = stream.read_numeric_bits(9)
        return str(stream.read_string(bytelength))
