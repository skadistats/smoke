from smoke.io.stream cimport generic


cdef class Decoder(object):
    cdef public object recv_table
    cdef void **_decoders

    cdef dict decode(Decoder self, generic.Stream stream, list prop_list)
