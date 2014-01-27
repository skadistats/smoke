from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.model cimport entity as mdl_ntt
from smoke.model.dt cimport recv_table as mdl_dt_rcvtbl


cdef class Decoder(object):
    cdef public object recv_table
    cdef dict decoders

    cdef mdl_ntt.State decode_baseline(Decoder self, io_strm_gnrc.Stream stream)

    cdef mdl_ntt.State decode(Decoder self, io_strm_gnrc.Stream stream, list prop_list)
