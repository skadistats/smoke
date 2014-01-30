# cython: profile=False

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.model.dt cimport prop as mdl_dt_prp
from smoke.replay.decoder.recv_prop cimport abstract


cdef class Decoder(abstract.Decoder):
    def __init__(Decoder self, mdl_dt_prp.Prop prop):
        abstract.Decoder.__init__(self, prop)

        assert prop.flags ^ mdl_dt_prp.ENCODEDAGAINSTTICKCOUNT

        self.unsign = prop.flags & mdl_dt_prp.UNSIGNED
        self.bits = prop.bits

    cpdef int decode(Decoder self, io_strm_gnrc.Stream stream):
        cdef:
            long l, r, v
            bint negate
            int remainder

        negate = False
        remainder = self.bits - 32

        if not self.unsign:
            remainder -= 1
            negate = stream.read_numeric_bits(1)

        l = stream.read_numeric_bits(32)
        r = stream.read_numeric_bits(remainder)
        v = (l << 32) | r

        return -v if negate else v
