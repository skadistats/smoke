

cpdef StringDecoder mk(object prop):
    return StringDecoder(prop)


cdef class StringDecoder(object):
    cdef public object prop

    def __init__(StringDecoder self, prop):
        self.prop = prop

    cpdef decode(StringDecoder self, object stream):
        cdef int bytelength = stream.read_numeric_bits(9)
        return stream.read_string(bytelength)
