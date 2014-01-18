from smoke.model.entity import Entity, PVS
from smoke.replay.decoder import dt as dcdr_dt


def mk(recv_tables):
    return PacketEntitiesDecoder(recv_tables)


class PacketEntitiesDecoder(object):
    def __init__(self, recv_tables):
        self.recv_tables = recv_tables
        self.class_bits = len(recv_tables.by_cls).bit_length()
        self.decoders = dict()

    def __getitem__(self, cls):
        if cls in self.decoders:
            return self.decoders[cls]

        decoder = dcdr_dt.mk(self.recv_tables.by_cls[cls])
        self.decoders[cls] = decoder

        return decoder

    def decode(self, stream, is_delta, count, world):
        index = -1
        patch = []

        while len(patch) < count:
            pvs, entry = self._decode_diff(stream, index, world)
            index = entry.index
            patch.append((pvs, entry))

        if is_delta:
            patch += self._decode_deletion_diffs(stream)

        return patch

    def _decode_diff(self, stream, index, entities):
        index = stream.read_entity_index(index)
        pvs = stream.read_entity_pvs()

        if pvs == PVS.Enter:
            cls = stream.read_numeric_bits(self.class_bits)
            serial = stream.read_numeric_bits(10)
            prop_list = stream.read_entity_prop_list()
            state = self[cls].decode(stream, prop_list)
        elif pvs == PVS.Preserve:
            _, entity = entities.entry_by_index[index]
            cls, serial = entity.cls, entity.serial
            prop_list = stream.read_entity_prop_list()
            state = self[cls].decode(stream, prop_list)
        elif pvs in (PVS.Leave, PVS.Delete):
            serial, cls, state = None, None, dict()

        return pvs, Entity(index, serial, cls, state)

    def _decode_deletion_diffs(self, stream):
        deletions = []

        while stream.read_numeric_bits(1):
            index = stream.read_numeric_bits(11) # max is 2^11-1, or 2047
            deletions.append((PVS.Delete, Entity(index, None, None, None)))

        return deletions
