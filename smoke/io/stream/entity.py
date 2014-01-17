from smoke.io.stream.generic import Stream
from smoke.model.entity import PVS


def mk(*args):
    return EntityStream(*args)


class EntityStream(Stream):
    def __init__(self, *args):
        super(EntityStream, self).__init__(*args)

    def read_entity_index(self, base_index):
        encoded_index = self.read_numeric_bits(6)

        if encoded_index & 0x30:
            # no idea how this actually works, but it does
            a = (encoded_index >> 4) & 3
            b = 16 if a == 3 else 0
            i = self.read_numeric_bits(4 * a + b) << 4
            encoded_index = i | (encoded_index & 0x0f)

        return base_index + encoded_index + 1

    def read_entity_pvs(self):
        hi = self.read_numeric_bits(1)
        lo = self.read_numeric_bits(1)

        if lo and not hi:
            pvs = PVS.Enter
        elif not (hi or lo):
            pvs = PVS.Preserve
        elif hi:
            pvs = PVS.Leave
            pvs = pvs | PVS.Delete if lo else pvs

        return pvs

    def read_entity_prop_list(self):
        prop_list = []
        cursor = -1

        while True:
            if self.read_numeric_bits(1):
                cursor += 1
            else:
                offset = self.read_varint()
                if offset == 0x3fff:
                    return prop_list
                else:
                    cursor += offset + 1

            prop_list.append(cursor)
