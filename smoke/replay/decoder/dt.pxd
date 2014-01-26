from smoke.io.stream cimport generic


cdef class Decoder(object):
    cdef public object recv_table
    cdef public list by_index
    cdef public dict by_recv_prop
    cdef dict cache

    cdef dict decode(Decoder self, generic.Stream stream, list prop_list)
