# cython: profile=False

from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport abstract


cpdef ArrayDecoder mk(object prop, object array_prop_decoder):
    return ArrayDecoder(prop, array_prop_decoder)


cdef class ArrayDecoder(abstract.AbstractDecoder):
    def __init__(ArrayDecoder self, object prop, object array_prop_decoder):
        abstract.AbstractDecoder.__init__(self, prop)

        shift, bits = prop.len, 0

        # there is probably a more concise way to do this
        while shift:
            shift >>= 1
            bits += 1

        self.bits = bits
        self.decoder = array_prop_decoder

    cpdef object decode(ArrayDecoder self, generic.Stream stream):
        cdef int count = stream.read_numeric_bits(self.bits)
        return [self.decoder.decode(stream) for _ in range(count)]
