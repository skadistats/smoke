# cython: profile=False

from libc cimport stdlib
from python_ref cimport PyObject, Py_DECREF, Py_INCREF

from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport factory as dcdr_rcvprp_fctry

from smoke.model.dt.const import Prop


cdef class Decoder(object):
    def __init__(Decoder self, object recv_table):
        cdef int bytesize = len(recv_table) * sizeof(void *)
        cdef object decoder

        self.recv_table = recv_table
        self._decoders = <void **>stdlib.malloc(bytesize)

        for i, recv_prop in enumerate(recv_table):
            decoder = dcdr_rcvprp_fctry.mk(recv_prop)
            Py_INCREF(decoder)
            self._decoders[i] = <void *>decoder

    def __dealloc__(self):
        if self._decoders != NULL:
            for i in range(len(self.recv_table)):
                Py_DECREF(<object>self._decoders[i])
            stdlib.free(self._decoders)

    cdef dict decode(Decoder self, io_strm_gnrc.Stream stream, list prop_list):
        cdef dict attrs = dict()

        for i in prop_list:
            decoder = <object>self._decoders[i]
            attrs[i] = decoder.decode(stream)

        return attrs
