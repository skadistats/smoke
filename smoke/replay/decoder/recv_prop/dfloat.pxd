from smoke.io.stream cimport generic as io_strm_gnrc
from smoke.replay.decoder.recv_prop cimport abstract


cdef:
    int COORD_INTEGER_BITS
    int COORD_FRACTIONAL_BITS
    int COORD_DENOMINATOR
    float COORD_RESOLUTION

    int COORD_INTEGER_BITS_MP
    int COORD_FRACTIONAL_BITS_MP_LOWPRECISION
    int COORD_DENOMINATOR_LOWPRECISION
    float COORD_RESOLUTION_LOWPRECISION

    int NORMAL_FRACTIONAL_BITS
    int NORMAL_DENOMINATOR
    float NORMAL_RESOLUTION


cdef class Decoder(abstract.Decoder):
    cdef:
        public int flags
        public int bits
        public float low
        public float high

    cpdef float decode(Decoder self, io_strm_gnrc.Stream stream)
    cdef float _decode_coord(Decoder self, io_strm_gnrc.Stream stream)
    cdef float _decode_coord_mp(Decoder self, io_strm_gnrc.Stream stream, bint integral, bint low_precision)
    cdef float _decode_no_scale(self, io_strm_gnrc.Stream stream)
    cdef float _decode_normal(self, io_strm_gnrc.Stream stream)
    cdef float _decode_cell_coord(self, io_strm_gnrc.Stream stream)
    cdef float _decode_cell_coord_integral(self, io_strm_gnrc.Stream stream)
    cdef float _decode_default(self, io_strm_gnrc.Stream stream)
