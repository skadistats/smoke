# cython: profile=False

from smoke.io.stream cimport generic
from smoke.model cimport entity as mdl_ntt


cdef class Stream(generic.Stream):
    def __init__(self, str data):
        generic.Stream.__init__(self, data)

    cdef int read_entity_index(Stream self, int base_index):
        cdef int encoded_index = self.read_numeric_bits(6)
        cdef int a, b, i

        if encoded_index & 0x30:
            # no idea how this actually works, but it does
            a = (encoded_index >> 4) & 3
            b = 16 if a == 3 else 0
            i = self.read_numeric_bits(4 * a + b) << 4
            encoded_index = i | (encoded_index & 0x0f)

        return base_index + encoded_index + 1

    cdef int read_entity_pvs(Stream self):
        cdef int hi, lo
        cdef int pvs

        hi = self.read_numeric_bits(1)
        lo = self.read_numeric_bits(1)

        if lo and not hi:
            pvs = mdl_ntt.ENTER
        elif not (hi or lo):
            pvs = mdl_ntt.PRESERVE
        elif hi:
            pvs = (mdl_ntt.LEAVE | mdl_ntt.DELETE) if lo else mdl_ntt.LEAVE
        else:
            pvs = -1

        return pvs

    cdef list read_entity_prop_list(Stream self):
        cdef list prop_list = list()
        cdef int cursor = -1
        cdef int offset

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
