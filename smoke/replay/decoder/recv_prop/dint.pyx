from smoke.model.dt.const import Flag


cpdef IntDecoder mk(object prop):
    return IntDecoder(prop)


cdef class IntDecoder(object):
    cdef public object prop
    cdef int _bits
    cdef long _eat
    cdef long _unsigned

    def __init__(IntDecoder self, object prop):
        self.prop = prop
        self._bits = prop.bits
        self._eat = prop.flags & Flag.EncodedAgainstTickcount
        self._unsigned = prop.flags & 1

    cpdef int decode(IntDecoder self, object stream):
        cdef long v, s

        if self._eat:
            v = stream.read_varint()

            if self._unsigned:
                return v # as is -- why?

            return (-(v & 1)) ^ (v >> 1)

        v = stream.read_numeric_bits(self._bits)
        s = (0x80000000 >> (32 - self._bits)) & (self._unsigned - 1)

        return (v ^ s) - s
