

cpdef DTDecoder mk(object recv_table)


cdef class DTDecoder(object):
    cdef public object recv_table
    cdef public object by_index
    cdef public object by_recv_prop
    cdef object cache

    cpdef object decode(DTDecoder self, object stream, object prop_list)
