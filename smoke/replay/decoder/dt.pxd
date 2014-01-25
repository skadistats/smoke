from smoke.io.stream cimport generic


cpdef DTDecoder mk(object recv_table)


cdef class DTDecoder(object):
    cdef public object recv_table
    cdef public list by_index
    cdef public dict by_recv_prop
    cdef dict cache

    cpdef dict decode(DTDecoder self, generic.Stream stream, list prop_list)
