from smoke.io.stream cimport entity as io_strm_ntt
from smoke.model.collection cimport entities as mdl_cllctn_ntts
from smoke.replay.decoder cimport dt as rply_dcdr_dt


cdef class Decoder(object):
    cdef public object recv_tables
    cdef public int class_bits
    cdef public dict decoders

    cdef rply_dcdr_dt.Decoder fetch_decoder(Decoder self, int cls)
    cdef list decode(Decoder self, object pb, mdl_cllctn_ntts.Collection entities)
    cdef tuple _decode_diff(Decoder self, io_strm_ntt.Stream stream, int index, mdl_cllctn_ntts.Collection entities)
    cdef list _decode_deletion_diffs(Decoder self, io_strm_ntt.Stream stream)
