# cython: profile=False

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract


cdef class Decoder(abstract.AbstractDecoder):
    def __init__(Decoder self, object prop, object array_prop_decoder):
        abstract.AbstractDecoder.__init__(self, prop)

        shift, bits = prop.len, 0

        # there is probably a more concise way to do this
        while shift:
            shift >>= 1
            bits += 1

        self.bits = bits
        self.decoder = array_prop_decoder

    cpdef object decode(Decoder self, io_strm_gnrc.Stream stream):
        cdef int count = stream.read_numeric_bits(self.bits)
        return [self.decoder.decode(stream) for _ in range(count)]
