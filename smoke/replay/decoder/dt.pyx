# cython: profile=False

from smoke.model cimport entity as mdl_ntt
from smoke.model.dt cimport prop as mdl_dt_prp
from smoke.model.dt cimport recv_table as mdl_dt_rcvtbl
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

    cdef mdl_ntt.State decode_baseline(Decoder self, io_strm_gnrc.Stream stream):
        cdef int length = len(self.recv_table)
        cdef mdl_ntt.State baseline = mdl_ntt.State(length)

        for i in range(length):
            baseline.put(i, self.decoders[i].decode(stream))

        return baseline

    cdef mdl_ntt.State decode(Decoder self, io_strm_gnrc.Stream stream, list prop_list):
        cdef int length = len(self.recv_table)
        cdef mdl_ntt.State patch = mdl_ntt.State(length)

        for i in prop_list:
            patch.put(i, self.decoders[i].decode(stream))

        return patch
