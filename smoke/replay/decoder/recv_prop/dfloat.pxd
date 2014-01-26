from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract


cdef class Decoder(abstract.AbstractDecoder):
    cdef object _fn
    cdef int flags
    cdef int bits
    cdef int low
    cdef int high

    cpdef float decode(self, io_strm_gnrc.Stream stream)
    cdef float _decode_coord(self, io_strm_gnrc.Stream stream)
    cdef float _decode_no_scale(self, io_strm_gnrc.Stream stream)
    cdef float _decode_cell_coord(self, io_strm_gnrc.Stream stream)
    cdef float _decode_default(self, io_strm_gnrc.Stream stream)
    cdef float _decode_normal(self, io_strm_gnrc.Stream stream)
    cdef float _decode_cell_coord_integral(self, io_strm_gnrc.Stream stream)
