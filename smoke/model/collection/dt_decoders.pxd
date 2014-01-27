from smoke.model.collection cimport recv_tables as mdl_cllctn_rcvtbls
from smoke.replay.decoder cimport dt as rply_dcdr_dt


cdef class Collection(object):
    cdef mdl_cllctn_rcvtbls.Collection recv_tables
    cdef dict _by_cls

    cdef rply_dcdr_dt.Decoder get(Collection self, int cls)
