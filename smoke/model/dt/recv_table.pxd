

cdef class RecvTable(object):
    cdef public object dt
    cdef public list recv_props
    cdef object _by_src
    cdef object _by_name
    cdef dict _by_tuple
