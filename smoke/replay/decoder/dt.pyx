# cython: profile=False

from cpython cimport Py_XINCREF, Py_XDECREF
from cpython.ref cimport PyObject
from libc.stdlib cimport calloc, free
from smoke.model cimport entity as mdl_ntt
from smoke.model.dt cimport prop as mdl_dt_prp
from smoke.model.dt cimport recv_table as mdl_dt_rcvtbl
from smoke.io.stream cimport entity as io_strm_ntt
from smoke.replay.decoder.recv_prop cimport abstract as rply_dcdr_rcvprp_bstrct


cdef class Decoder(object):
    def __cinit__(Decoder self, object recv_table):
        cdef mdl_dt_prp.Prop recv_prop
        cdef rply_dcdr_rcvprp_bstrct.Decoder prop_decoder

        self.recv_table = recv_table
        self._length = len(recv_table)
        self._store = <PyObject **>calloc(self._length, sizeof(PyObject *))

        for i, _recv_prop in enumerate(recv_table):
            recv_prop = <mdl_dt_prp.Prop>_recv_prop
            prop_decoder = recv_prop.mk()
            Py_XINCREF(<PyObject *>prop_decoder)
            self._store[i] = <PyObject *>prop_decoder

    def __dealloc__(self):
        cdef int i

        if self._store != NULL:
            for i in range(self._length):
                Py_XDECREF(<PyObject *>self._store[i])
            free(self._store)

    cdef mdl_ntt.State decode_baseline(Decoder self, io_strm_ntt.Stream stream):
        cdef mdl_ntt.State baseline = mdl_ntt.State(self._length)
        cdef rply_dcdr_rcvprp_bstrct.Decoder decoder
        cdef object value

        for i in range(self._length):
            decoder = <rply_dcdr_rcvprp_bstrct.Decoder>self._store[i]
            value = decoder.decode(stream)
            baseline.put(i, value)

        return baseline

    cdef mdl_ntt.State decode(Decoder self, io_strm_ntt.Stream stream, list prop_list):
        cdef mdl_ntt.State patch = mdl_ntt.State(self._length)
        cdef rply_dcdr_rcvprp_bstrct.Decoder decoder
        cdef object value

        for i in prop_list:
            decoder = <rply_dcdr_rcvprp_bstrct.Decoder>self._store[i]
            value = decoder.decode(stream)
            patch.put(i, value)

        return patch
