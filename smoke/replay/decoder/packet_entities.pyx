# cython: profile=False

from smoke.io.stream cimport entity
from smoke.replay.decoder cimport dt as dcdr_dt

from smoke.model.const import Entity, PVS


cdef int Enter = PVS.Enter
cdef int Preserve = PVS.Preserve
cdef int Leave = PVS.Leave
cdef int Delete = PVS.Delete


cpdef PacketEntitiesDecoder mk(recv_tables):
    return PacketEntitiesDecoder(recv_tables)


cdef class PacketEntitiesDecoder(object):
    def __init__(PacketEntitiesDecoder self, object recv_tables):
        self.recv_tables = recv_tables
        self.class_bits = len(recv_tables.by_cls).bit_length()
        self.decoders = dict()

    cpdef fetch_decoder(PacketEntitiesDecoder self, int cls):
        cdef dcdr_dt.DTDecoder decoder

        if cls in self.decoders:
            return self.decoders[cls]

        decoder = dcdr_dt.mk(self.recv_tables.by_cls[cls])
        self.decoders[cls] = decoder

        return decoder

    cpdef object decode(PacketEntitiesDecoder self, entity.Stream stream, int is_delta, int count, object world):
        cdef int index = -1
        cdef list patch = list()

        while len(patch) < count:
            pvs, entry = self._decode_diff(stream, index, world)
            index = entry.index
            patch.append((pvs, entry))

        if is_delta:
            patch += self._decode_deletion_diffs(stream)

        return patch

    cdef _decode_diff(PacketEntitiesDecoder self, entity.Stream stream, int i, object entities):
        cdef int diff_index = stream.read_entity_index(i)
        cdef int pvs = stream.read_entity_pvs()
        cdef list prop_list
        cdef dict state
        cdef dcdr_dt.DTDecoder decoder

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

    cdef _decode_deletion_diffs(PacketEntitiesDecoder self, entity.Stream stream):
        cdef int deletion_index
        cdef list deletions = list()

        while stream.read_numeric_bits(1):
            deletion_index = stream.read_numeric_bits(11) # max is 2^11-1, or 2047
            deletions.append((Delete, Entity(deletion_index, None, None, None)))

        return deletions
