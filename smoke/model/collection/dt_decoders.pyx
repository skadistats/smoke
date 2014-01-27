# cython: profile=False

from smoke.model.collection cimport recv_tables as mdl_cllctn_rcvtbls
from smoke.replay.decoder cimport dt as rply_dcdr_dt


cdef class Collection(object):
    def __cinit__(Collection self, mdl_cllctn_rcvtbls.Collection recv_tables):
        self.recv_tables = recv_tables
        self._by_cls = dict()

    cdef rply_dcdr_dt.Decoder get(Collection self, int cls):
        cdef rply_dcdr_dt.Decoder decoder

        if cls in self._by_cls:
            return self._by_cls[cls]

        decoder = rply_dcdr_dt.Decoder(self.recv_tables.by_cls[cls])
        self._by_cls[cls] = decoder

        return decoder
