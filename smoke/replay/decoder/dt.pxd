from smoke.io.stream cimport generic as io_strm_gnrc


cdef class Decoder(object):
    cdef public object recv_table
    cdef dict decoders

    cdef dict decode(Decoder self, io_strm_gnrc.Stream stream, list prop_list)
