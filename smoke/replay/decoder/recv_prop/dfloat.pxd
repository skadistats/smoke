

cpdef FloatDecoder mk(object prop)


cdef class FloatDecoder(object):
    cdef public object prop
    cdef object _fn
    cdef int _bits
    cdef int _low
    cdef int _high

    cpdef float decode(self, stream)
    cpdef float _decode_coord(self, stream)
    cpdef float _decode_no_scale(self, stream)
    cpdef float _decode_cell_coord(self, stream)
    cpdef float _decode_default(self, stream)
    cpdef float _decode_normal(self, stream)
    cpdef float _decode_cell_coord_integral(self, stream)
