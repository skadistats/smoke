# cython: profile=False

from smoke.io.stream cimport generic

from smoke.model.dt.const import Flag
from smoke.replay.decoder.recv_prop cimport abstract


cpdef IntDecoder mk(object prop):
    return IntDecoder(prop)


cdef class IntDecoder(abstract.AbstractDecoder):
    def __init__(IntDecoder self, object prop):
        abstract.AbstractDecoder.__init__(self, prop)
        self.bits = prop.bits
        self.eat = prop.flags & Flag.EncodedAgainstTickcount
        self.unsign = prop.flags & 1

    cpdef int decode(IntDecoder self, generic.Stream stream):
        cdef long v, s

        if self.eat:
            v = stream.read_varint()

            if self.unsign:
                return v # as is -- why?

            return (-(v & 1)) ^ (v >> 1)

        v = stream.read_numeric_bits(self.bits)
        s = (0x80000000 >> (32 - self.bits)) & (self.unsign - 1)

        return (v ^ s) - s
