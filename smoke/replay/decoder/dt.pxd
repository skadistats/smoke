from cpython.ref cimport PyObject
from smoke.io.stream cimport entity as io_strm_ntt
from smoke.model cimport entity as mdl_ntt
from smoke.model.dt cimport recv_table as mdl_dt_rcvtbl


cdef class Decoder(object):
    cdef public object recv_table
    cdef int _length
    cdef PyObject **_store

    cdef mdl_ntt.State decode_baseline(Decoder self, io_strm_ntt.Stream stream)

    cdef mdl_ntt.State decode(Decoder self, io_strm_ntt.Stream stream, list prop_list)
