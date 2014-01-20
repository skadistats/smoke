from smoke.io.stream cimport generic
from smoke.model.entity import PVS


cpdef EntityStream mk(str data):
    return EntityStream(data)


cdef class EntityStream(generic.Stream):
    def __init__(self, str data):
        super(EntityStream, self).__init__(data)

    cpdef int read_entity_index(EntityStream self, int base_index):
        cdef int encoded_index = self.read_numeric_bits(6)
        cdef int a, b, i

        if encoded_index & 0x30:
            # no idea how this actually works, but it does
            a = (encoded_index >> 4) & 3
            b = 16 if a == 3 else 0
            i = self.read_numeric_bits(4 * a + b) << 4
            encoded_index = i | (encoded_index & 0x0f)

        return base_index + encoded_index + 1

    cpdef int read_entity_pvs(EntityStream self):
        cdef int hi, lo

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

    cpdef list read_entity_prop_list(self):
        cdef list prop_list = []
        cdef int cursor = -1
        cdef int offsest

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
