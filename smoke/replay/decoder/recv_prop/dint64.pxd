from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract

from smoke.model.dt.const import Flag


cdef class Decoder(abstract.AbstractDecoder):
    cdef int bits
    cdef long unsign

    cpdef int decode(Decoder self, io_strm_gnrc.Stream stream)
