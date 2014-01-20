

cpdef ArrayDecoder mk(object prop, object array_prop_decoder):
    return ArrayDecoder(prop, array_prop_decoder)


cdef class ArrayDecoder(object):
    cdef public object prop
    cdef public object decoder
    cdef int _bits

    def __init__(ArrayDecoder self, object prop, object array_prop_decoder):
        self.prop = prop

        shift, bits = prop.len, 0

        # there is probably a more concise way to do this
        while shift:
            shift >>= 1
            bits += 1

        self._bits = bits
        self.decoder = array_prop_decoder

    cpdef object decode(ArrayDecoder self, object stream):
        count = stream.read_numeric_bits(self._bits)
        return [self.decoder.decode(stream) for _ in range(count)]
