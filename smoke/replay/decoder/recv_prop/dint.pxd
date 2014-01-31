from libc.stdint cimport int32_t
from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract


cdef class Decoder(abstract.Decoder):
    cdef:
        int bits
        bint eat
        bint unsign

    cpdef int32_t decode(Decoder self, io_strm_gnrc.Stream stream)
