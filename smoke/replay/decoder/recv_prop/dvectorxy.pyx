# cython: profile=False

import math

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.model.dt cimport prop as mdl_dt_prp
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport dfloat


cdef class Decoder(abstract.Decoder):
    def __init__(Decoder self, mdl_dt_prp.Prop prop):
        abstract.Decoder.__init__(self, prop)
        self.decoder = dfloat.Decoder(prop)

    cpdef tuple decode(Decoder self, io_strm_gnrc.Stream stream):
        cdef:
            float x = self.decoder.decode(stream)
            float y = self.decoder.decode(stream)

        return x, y
