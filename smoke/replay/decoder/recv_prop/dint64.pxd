from libc.stdint cimport int64_t
from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract


cdef class Decoder(abstract.Decoder):
    cdef:
        bint unsign
        int bits

    cpdef int64_t decode(Decoder self, io_strm_gnrc.Stream stream)
