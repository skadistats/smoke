# cython: profile=False

from smoke.io.stream cimport entity as io_strm_ntt
from smoke.replay.decoder cimport dt as rply_dcdr_dt

from smoke.model.const import Entity, PVS


cdef int Enter = PVS.Enter
cdef int Preserve = PVS.Preserve
cdef int Leave = PVS.Leave
cdef int Delete = PVS.Delete


cdef class Decoder(object):
    def __init__(Decoder self, object recv_tables, int class_bits):
        self.recv_tables = recv_tables
        self.class_bits = len(recv_tables.by_cls).bit_length()
        self.decoders = dict()

    cdef rply_dcdr_dt.Decoder fetch_decoder(Decoder self, int cls):
        cdef rply_dcdr_dt.Decoder decoder

        if cls in self.decoders:
            return self.decoders[cls]

        decoder = rply_dcdr_dt.Decoder(self.recv_tables.by_cls[cls])
        self.decoders[cls] = decoder

        return decoder

    cdef list decode(Decoder self, object pb, mdl_cllctn_ntts.Collection entities):
        cdef int index = -1
        cdef list patch = list()
        cdef io_strm_ntt.Stream stream = io_strm_ntt.Stream(pb.entity_data)
        cdef int count = pb.updated_entries

        while len(patch) < count:
            pvs, entry = self._decode_diff(stream, index, entities)
            index = entry.index
            patch.append((pvs, entry))

        if pb.is_delta:
            patch += self._decode_deletion_diffs(stream)

        return patch

    cdef tuple _decode_diff(Decoder self, io_strm_ntt.Stream stream, int i, mdl_cllctn_ntts.Collection entities):
        cdef int diff_index = stream.read_entity_index(i)
        cdef int pvs = stream.read_entity_pvs()
        cdef list prop_list
        cdef dict state
        cdef rply_dcdr_dt.Decoder decoder

        if pvs == Enter:
            cls = stream.read_numeric_bits(self.class_bits)
            serial = stream.read_numeric_bits(10)
            prop_list = stream.read_entity_prop_list()
            decoder = self.fetch_decoder(cls)
            state = decoder.decode(stream, prop_list)
        elif pvs == Preserve:
            _, entity = entities.entry_by_index[diff_index]
            cls, serial = entity.cls, entity.serial
            prop_list = stream.read_entity_prop_list()
            decoder = self.fetch_decoder(cls)
            state = decoder.decode(stream, prop_list)
        elif pvs in (Leave, Delete):
            serial, cls, state = None, None, dict()

        return pvs, Entity(diff_index, serial, cls, state)

    cdef list _decode_deletion_diffs(Decoder self, io_strm_ntt.Stream stream):
        cdef int deletion_index
        cdef list deletions = list()

        while stream.read_numeric_bits(1):
            deletion_index = stream.read_numeric_bits(11) # max is 2^11-1, or 2047
            deletions.append((Delete, Entity(deletion_index, None, None, None)))

        return deletions
