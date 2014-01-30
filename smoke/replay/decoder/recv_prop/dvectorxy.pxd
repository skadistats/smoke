from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport dfloat


cdef class Decoder(abstract.Decoder):
    cdef public dfloat.Decoder decoder

    cpdef tuple decode(Decoder self, io_strm_gnrc.Stream stream)
