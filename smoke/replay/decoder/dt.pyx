# cython: profile=False

from smoke.model.dt cimport prop as mdl_dt_prp
from smoke.io.stream cimport generic as io_strm_gnrc


cdef class Decoder(object):
    def __init__(Decoder self, object recv_table):
        cdef int bytesize = len(recv_table) * sizeof(void *)
        cdef object decoder
        cdef mdl_dt_prp.Prop _recv_prop

        self.recv_table = recv_table
        self.decoders = dict()

        for i, recv_prop in enumerate(recv_table):
            _recv_prop = <mdl_dt_prp.Prop>recv_prop
            self.decoders[i] = _recv_prop.mk()

    cdef dict decode(Decoder self, io_strm_gnrc.Stream stream, list prop_list):
        cdef dict attrs = dict()

        for i in prop_list:
            attrs[i] = self.decoders[i].decode(stream)

        return attrs
