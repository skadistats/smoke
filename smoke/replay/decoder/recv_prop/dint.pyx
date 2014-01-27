# cython: profile=False

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.model.dt cimport prop as mdl_dt_prp
from smoke.replay.decoder.recv_prop cimport abstract


cdef class Decoder(abstract.Decoder):
    def __init__(Decoder self, object prop):
        abstract.Decoder.__init__(self, prop)
        self.bits = prop.bits
        self.eat = prop.flags & mdl_dt_prp.ENCODEDAGAINSTTICKCOUNT
        self.unsign = prop.flags & 1

    cpdef int decode(Decoder self, io_strm_gnrc.Stream stream):
        cdef long v, s

        if self.eat:
            v = stream.read_varint()

            if self.unsign:
                return v # as is -- why?

            return (-(v & 1)) ^ (v >> 1)

        v = stream.read_numeric_bits(self.bits)
        s = (0x80000000 >> (32 - self.bits)) & (self.unsign - 1)

        return (v ^ s) - s
