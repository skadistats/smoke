from smoke.replay.decoder cimport dt as dcdr_dt
from smoke.model.entity import Entity, PVS


cpdef PacketEntitiesDecoder mk(recv_tables):
    return PacketEntitiesDecoder(recv_tables)


cdef class PacketEntitiesDecoder(object):
    def __init__(PacketEntitiesDecoder self, object recv_tables):
        self.recv_tables = recv_tables
        self.class_bits = len(recv_tables.by_cls).bit_length()
        self.decoders = dict()

    def __getitem__(PacketEntitiesDecoder self, int cls):
        cdef object decoder

        if cls in self.decoders:
            return self.decoders[cls]

        decoder = dcdr_dt.mk(self.recv_tables.by_cls[cls])
        self.decoders[cls] = decoder

        return decoder

    cpdef object decode(PacketEntitiesDecoder self, object stream, int is_delta, int count, object world):
        cdef int index = -1
        cdef object patch = []

        while len(patch) < count:
            pvs, entry = self._decode_diff(stream, index, world)
            index = entry.index
            patch.append((pvs, entry))

        if is_delta:
            patch += self._decode_deletion_diffs(stream)

        return patch

    cdef _decode_diff(PacketEntitiesDecoder self, object stream, int i, object entities):
        cdef int diff_index = stream.read_entity_index(i)
        cdef int pvs = stream.read_entity_pvs()

        if pvs == PVS.Enter:
            cls = stream.read_numeric_bits(self.class_bits)
            serial = stream.read_numeric_bits(10)
            prop_list = stream.read_entity_prop_list()
            state = self[cls].decode(stream, prop_list)
        elif pvs == PVS.Preserve:
            _, entity = entities.entry_by_index[diff_index]
            cls, serial = entity.cls, entity.serial
            prop_list = stream.read_entity_prop_list()
            state = self[cls].decode(stream, prop_list)
        elif pvs in (PVS.Leave, PVS.Delete):
            serial, cls, state = None, None, dict()

        return pvs, Entity(diff_index, serial, cls, state)

    cdef _decode_deletion_diffs(PacketEntitiesDecoder self, stream):
        cdef int deletion_index
        cdef object deletions

        deletions = []

        while stream.read_numeric_bits(1):
            deletion_index = stream.read_numeric_bits(11) # max is 2^11-1, or 2047
            deletions.append((PVS.Delete, Entity(deletion_index, None, None, None)))

        return deletions
