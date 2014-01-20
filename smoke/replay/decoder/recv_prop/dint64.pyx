from smoke.model.dt.const import Flag


cpdef IntDecoder mk(object prop):
    return IntDecoder(prop)


cdef class IntDecoder(object):
    cdef public object prop
    cdef int _bits
    cdef long _unsigned

    def __init__(IntDecoder self, object prop):
        self.prop = prop

        assert prop.flags ^ Flag.EncodedAgainstTickcount

        self._unsigned = prop.flags & Flag.Unsigned
        self._bits = prop.bits

    cpdef int decode(IntDecoder self, object stream):
        cdef long l, r, v
        cdef int negate
        cdef int remainder

        negate = 0
        remainder = self._bits - 32

        if not self._unsigned:
            remainder -= 1
            if stream.read_numeric_bits(1):
                negate = 1

        l = stream.read_numeric_bits(32)
        r = stream.read_numeric_bits(remainder)
        v = (l << 32) | r

        if negate:
            v *= -1

        return v
